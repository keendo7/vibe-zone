class CleanupNotificationsJob
  include Sidekiq::Job

  def perform()
    Notification.deprecated.delete_all
  end
end
