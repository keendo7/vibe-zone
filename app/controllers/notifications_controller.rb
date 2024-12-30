class NotificationsController < ApplicationController
  before_action :authenticate_user!
  after_action :mark_as_read, only: :index

  def index
    @pagy, @notifications = pagy_countless(current_user.notifications, items: 20)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private
  
  def mark_as_read
    current_user.notifications.were_not_read.each(&:read)
  end
end
