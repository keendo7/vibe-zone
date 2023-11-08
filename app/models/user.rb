class User < ApplicationRecord
  before_save :set_firstname, :set_lastname
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :authored_posts, foreign_key: 'author_id', class_name: 'Post', dependent: :destroy
  has_many :created_comments, foreign_key: 'commenter_id', class_name: 'Comment', dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :received_friendships, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :received_friends, through: :received_friendships, source: 'user'
  has_many :likes, dependent: :destroy

  validates :first_name, length: { in: 2..40 }
  validates :last_name, length: { in: 2..40 }
  
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

  private
  
  def set_firstname
    self.first_name = self.first_name.strip.titlecase
  end

  def set_lastname
    self.last_name = self.last_name.strip.titlecase
  end
end
