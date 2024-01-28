require 'open-uri'

class User < ApplicationRecord
  include Gravtastic
  extend FriendlyId
  gravtastic
  friendly_id :full_name, use: :sequentially_slugged
  before_save :set_firstname, :set_lastname
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[facebook]
  
  has_many :authored_posts, foreign_key: 'author_id', class_name: 'Post', dependent: :destroy
  has_many :created_comments, foreign_key: 'commenter_id', class_name: 'Comment', dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :received_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :received_friends, through: :received_friendships, source: 'user'
  has_many :likes, dependent: :destroy
  has_one_attached :avatar

  validates :first_name, length: { in: 2..40 }
  validates :last_name, length: { in: 2..40 }
  validates :avatar, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 1..(5.megabytes) }

  scope :search, ->(query) { where("CONCAT_WS(' ', first_name, last_name) ILIKE ?", "%#{query}%") }
  
  def active_friends
    friends.select{ |friend| friend.friends.include?(self) }  
  end
  
  def pending_friends
    friends.select{ |friend| !friend.friends.include?(self) }  
  end

  def timeline
    friend_ids = self.active_friends.pluck(:id)
    Post.where(author_id: [self.id] + friend_ids)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def remove_friendship(friendship)
    if friendship.is_mutual
      inverse_friendship = friendship.friend.friendships.find_by(friend: self)
      transaction do
        friendship.destroy
        inverse_friendship.destroy
      end
    else
      friendship.destroy
    end
  end

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.name.split(" ")[0]
      user.last_name = auth.info.name.split(" ")[1] 
      url = URI.parse(auth.info.image)
      filename = File.basename(url.path)
      file = URI.open(url)
      user.avatar.attach(io: file, filename: filename)

      user.save!
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
