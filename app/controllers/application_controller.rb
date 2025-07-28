class ApplicationController < ActionController::Base
  include Pagy::Backend
  include ActionView::RecordIdentifier
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:first_name, :last_name, :email, :password, :password_confirmation)}

    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:first_name, :last_name, :email, :password, :current_password, :avatar)}
  end

  private
  def referer_path
    URI(request.referer || '').path
  rescue URI::InvalidURIError
    nil
  end
end
