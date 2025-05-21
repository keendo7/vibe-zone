class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(was_read: false) }
  scope :deprecated, -> { where(was_read: true).where('created_at <= ?', 7.days.ago) }

  broadcasts_to ->(notification) { [notification.user, "notifications_count"] }, inserts_by: :prepend
  
  after_create_commit { broadcast_notifications_count_create }
  after_destroy_commit { broadcast_notifications_count_destroy }

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

  private

  def broadcast_notifications_count_destroy
    return if user.nil? || !user.persisted?

    broadcast_replace_to [user, "notifications_count"],
                          target: "notifications_title", 
                          partial: "shared/notifications_title", 
                          locals: { new_notifications_count: user.new_notifications_count }

    broadcast_replace_to [user, "notifications_count"],
                          target: "notifications_link",
                          partial: "shared/notifications_link",
                          locals: { new_notifications_count: user.new_notifications_count }
  end

  def broadcast_notifications_count_create
    broadcast_replace_later_to [user, "notifications_count"],
                          target: "notifications_title", 
                          partial: "shared/notifications_title", 
                          locals: { new_notifications_count: user.new_notifications_count }

    broadcast_replace_later_to [user, "notifications_count"],
                          target: "notifications_link",
                          partial: "shared/notifications_link",
                          locals: { new_notifications_count: user.new_notifications_count }
  end
end
