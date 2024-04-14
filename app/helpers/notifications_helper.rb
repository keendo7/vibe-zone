module NotificationsHelper
  def content(notification)
    if notification.is_a_like?
      notification.notifiable.likeable.content
    else
      notification.notifiable.content
    end
  end

  def notifiable_link(notification)
    if notification.is_a_like?
      if notification.notifiable.is_a_comment?
        notification.notifiable.likeable.commentable
      else
        notification.notifiable.likeable
      end
    else
      notification.notifiable.commentable
    end
  end

  def notifications_count(user)
    count = user.new_notifications_count

    if count >= 1 && count < 10
      "(#{count})"
    elsif count >= 10
      return "(9+)"
    end
  end
end
