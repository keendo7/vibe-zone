require 'open-uri'

class User < ApplicationRecord
  include Gravtastic
  extend FriendlyId

  AVATAR_CONTENT_TYPES = ["image/jpeg", "image/png"].freeze

  gravtastic
  friendly_id :full_name, use: :sequentially_slugged
  before_save :set_firstname, :set_lastname
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[facebook google_oauth2]
  
  has_many :authored_posts, -> { order(created_at: :desc) }, foreign_key: 'author_id', class_name: 'Post', dependent: :destroy
  has_many :created_comments, foreign_key: 'commenter_id', class_name: 'Comment', dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :received_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :received_friends, through: :received_friendships, source: 'user'
  has_many :likes, dependent: :destroy
  has_many :notifications, -> { order(was_read: :asc, created_at: :desc) }, dependent: :destroy
  has_one_attached :avatar

  validates :first_name, :last_name, presence: true, format: {with: /\A\D{2,}\z/ }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :avatar, content_type: AVATAR_CONTENT_TYPES, size: { less_than: 5.megabytes}

  scope :search, ->(query) { where("CONCAT_WS(' ', first_name, last_name) ILIKE ?", "%#{query}%") }
  
  def active_friends
    friends.select{ |friend| friend.friends.include?(self) }  
  end
  
  def pending_friends
    friends.select{ |friend| !friend.friends.include?(self) }  
  end

  def friendship_status_with(user)
    if is_friends_with?(user)
      return :friend, friendships.find_by(friend: user)
    elsif received_friendship_request_from?(user)
      return :request, received_friendship_request_from(user)
    else 
      return :no_friendship, nil
    end 
  end

  def active_friendships
    friend_ids = active_friends.pluck(:id)
    friendships.includes(:friend).where(friend_id: friend_ids)
  end

  def mutual_friends(user)
    friendships.select do |friend|
      user.friendships.find_by(friend_id: friend.friend_id)
    end
  end

  def new_notifications_count
    notifications.reject(&:was_read).count
  end

  def timeline
    friend_ids = self.active_friends.pluck(:id)
    Post.includes(:author).where(author_id: [self.id] + friend_ids).descending
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  
  def to_param
    slug
  end

  def is_friends_with?(user)
    active_friends.include?(user) || pending_friends.include?(user)
  end

  def received_friendship_request_from?(user) 
    received_friends.include?(user)
  end

  def received_friendship_request_from(user)
    received_friendships.find_by(user: user)
  end

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email || "#{auth.uid}@#{auth.provider}.com"
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.name.split(" ")[0]
      user.last_name = auth.info.name.split(" ")[1] 
      url = URI.parse(auth.info.image)
      filename = File.basename(url.path)
      file = URI.open(url)
      user.avatar.attach(io: file, filename: filename)
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  private

  def should_generate_new_friendly_id?
    first_name_changed? || last_name_changed?
   end   
  
  def set_firstname
    self.first_name = self.first_name.strip.titlecase
  end

  def set_lastname
    self.last_name = self.last_name.strip.titlecase
  end
end
