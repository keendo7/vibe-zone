class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'
  has_many :notifications, as: :notifiable, dependent: :destroy
  
  validates :user_id, presence: true, uniqueness: { scope: :friend_id }
  validates :friend_id, presence: true
  validate :user_is_not_equal_friend

  after_destroy :remove_reciprocal_friendship

  scope :search_friend, ->(query) { joins(:friend).where("CONCAT_WS(' ', first_name, last_name) ILIKE ?", "%#{query}%") }
  
  def is_mutual?
    Friendship.exists?(user: self.friend, friend: self.user)
  end

  def message
    if self.is_mutual?
      " became your friend!"
    elsif user.pending_friends.include?(friend)
      " sent you a friend request"
    end
  end
    
  private
  def remove_reciprocal_friendship
    friendship = friend.friendships.find_by(friend_id: user.id)
    friendship.destroy if friendship
  end

  def user_is_not_equal_friend
    errors.add(:friend, "can't be the same as the user") if self.user == self.friend
  end
end
