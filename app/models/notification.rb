class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(was_read: false) }
  scope :deprecated, -> { where(was_read: true).where('created_at <= ?', 7.days.ago) }

  broadcasts_to ->(notification) { [notification.user, "notifications_list"] }, inserts_by: :prepend

  def is_a_friend_request?
    return false unless notifiable_type == "Friendship"
    !self.notifiable.is_mutual?
  end

  def is_a_friendship?
    return false unless notifiable_type == "Friendship"
    self.notifiable.is_mutual?
  end

  def is_a_comment?
    notifiable_type == "Comment" && !self.notifiable.is_a_reply?
  end

  def is_a_reply?
    notifiable_type == "Comment" && self.notifiable.is_a_reply?
  end

  def is_a_like?
    notifiable_type == "Like"
  end

  def read
    self.was_read = true
    save
  end
end
