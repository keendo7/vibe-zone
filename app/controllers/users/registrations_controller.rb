class Users::RegistrationsController < Devise::RegistrationsController

  def create
    super
    if @user.persisted?
      UserRegisteredJob.perform_async(@user.id)
    end
  end
end
