class Api::V1::NotificationsController < Api::V1::BaseController
  def create
    notification = current_user.build_notification(default_settings)
    if notification.save
      LineNotificationJob.set(wait_until: notification.next_run_at).perform_later(notification.id, notification.next_run_at)
      head :no_content
    else
      render json: { errors: notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    notification = current_user.notification
    if notification
      json_string = NotificationSerializer.new(notification).serialize
      render json: json_string
    else
      head :no_content
    end
  end

  def update
    notification = current_user.notification
    if notification.update(notification_params)
      head :no_content
    else
      render json: { errors: notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def notification_params
    params.require(:notification).permit(:status)
  end

  def default_settings
    now = Time.zone.now
    {
      start_date: now,
      scheduled_time: Time.zone.local(now.year, now.month, now.day, 20),
      on_weekday: :saturday
    }
  end
end
