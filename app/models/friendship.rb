class Friendship < ApplicationRecord
    belongs_to :user
    belongs_to :friend, class_name: 'User'
  
    validates :user_id, presence: true, uniqueness: { scope: :friend_id }
    validates :friend_id, presence: true
    validate :user_is_not_equal_friend
  
    def is_mutual
      self.friend.friends.include?(self.user)
    end
  
    private
    def user_is_not_equal_friend
      errors.add(:friend, "can't be the same as the user") if self.user == self.friend
    end
end