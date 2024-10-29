class UserFriendshipRequestJob
  include Sidekiq::Job

  def perform(recipient_id, sender_id)
    recipient = User.friendly.find(recipient_id)
    sender = User.friendly.find(sender_id)
    UserMailer.user_friendship_request(recipient, sender).deliver_now
  end
end
