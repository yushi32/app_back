class LineNotificationJob < ApplicationJob
  include LineApiClient

  queue_as :default

  def perform(notification_id, prev_schedule)
    notification = Notification.find(notification_id)
    return unless notification

    user = notification.user
    messages, bookmarks_to_notify = build_messages_for_unnotified_bookmarks(user.id)
    if send_push_message(user.line_user_id, messages)
      bookmarks_to_notify.update_all(status: :notified, updated_at: Time.zone.now)
    end

    next_schedule = calculate_next_run(notification, prev_schedule)
    job = LineNotificationJob.set(wait_until: next_schedule).perform_later(notification_id, next_schedule)
    # 通知設定を変更した時に待機中のジョブを削除するためにDBにジョブIDを保持する
    job_id = job.provider_job_id
    notification.update(job_id: job_id)
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
