class UserMailer < ApplicationMailer

  default from: "from@example.com"

  layout "mailer"

  def user_registered_email(user)
    @user = user
    mail(to: user.email, subject: "Welcome to the Vibezone!")
  end

  def user_friendship_request(recipient, sender)
    @recipient = recipient
    @sender = sender
    mail(to: recipient.email, subject: "You got a new friendship request from #{sender.first_name}!")
  end
end
