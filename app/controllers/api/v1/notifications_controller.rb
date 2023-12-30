class Api::V1::NotificationsController < Api::V1::BaseController
  def create
    notification = current_user.build_notification(default_setting)
    if notification.save
      NotificationJob.set(wait_until: notification.next_run_at).perform_later(notification.id)
      head :no_content
    else
      render json: { errors: notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def default_setting
    now = Time.zone.now
    {
      start_date: now,
      scheduled_time: Time.zone.local(now.year, now.month, now.day, 20),
      on_weekday: :saturday
    }
  end
end
