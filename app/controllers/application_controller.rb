class ApplicationController < ActionController::Base
  include Pagy::Backend
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :turbo_frame_request_variant

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:first_name, :last_name, :email, :password, :password_confirmation)}

    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:first_name, :last_name, :email, :password, :current_password, :avatar)}
  end

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end
end
