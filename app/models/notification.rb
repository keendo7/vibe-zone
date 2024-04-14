class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  def is_a_friend_request?
    return unless notifiable_type == "Friendship"
    sender.pending_friends.include?(user)
  end

  def is_a_friendship?
    return if self.is_a_friend_request?
    return notifiable_type == "Friendship"
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
