class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
    @new = @notifications.reject(&:was_read)
    @old = @notifications.select(&:was_read)

    @notifications.each(&:read)
  end
end
