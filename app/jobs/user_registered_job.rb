class UserRegisteredJob
  include Sidekiq::Job

  def perform(user_id)
    user = User.friendly.find(user_id)
    UserMailer.user_registered_email(user).deliver_now
  end
end
