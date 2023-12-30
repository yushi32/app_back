class NotificationJob < ApplicationJob
  include LineApiClient

  queue_as :default

  def perform(notification_id, prev_schedule)
    notification = Notification.find_by(id: notification_id)
    return unless notification

    send_unread_bookmarks(notification.user.line_user_id)
    next_schedule = calculate_next_run(notification, prev_schedule)
    NotificationJob.set(wait_until: next_schedule).perform_later(notification_id, next_schedule)
  end

  private

  def calculate_next_run(notification, prev_schedule)
    if notification.on_weekday
      prev_schedule + 1.week
    elsif notification.interval_days
      prev_schedule + notification.interval_days.days
    end
  end
end