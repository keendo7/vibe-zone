class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  scope :were_not_read, -> { where(was_read: false) }
 
  def is_a_friend_request?
    return false unless notifiable_type == "Friendship"
    !self.notifiable.is_mutual
  end

  def is_a_friendship?
    return false unless notifiable_type == "Friendship"
    self.notifiable.is_mutual
  end

  def is_a_comment?
    notifiable_type == "Comment"
  end

  def is_a_like?
    notifiable_type == "Like"
  end

  def read
    self.was_read = true
    save
  end
end
