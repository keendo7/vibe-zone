class Users::RegistrationsController < Devise::RegistrationsController
  invisible_captcha only: [:create]

  def create
    super
    if @user.persisted?
      UserRegisteredJob.perform_async(@user.id)
    end
  end
end
