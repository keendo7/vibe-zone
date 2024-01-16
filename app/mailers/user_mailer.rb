class UserMailer < ApplicationMailer

  default from: "from@example.com"

  layout "mailer"

  def user_registered_email(user)
    @user = user
    mail(to: user.email, subject: "Welcome to the Vibezone!")
  end
end