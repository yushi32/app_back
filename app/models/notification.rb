class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :category, polymorphic: true, optional: true

  validates :start_date, presence: true
  validates :scheduled_time, presence: true
  validates :mode, presence: true
  validates :status, inclusion: { in: [true, false] }

  validate :valid_mode_matches_category_type

  enum on_weekday: { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }
  enum mode: { default: 0, folder_only: 1, tag_only: 2 }

  def valid_mode_matches_category_type
    return if default_mode? || folder_mode? || tag_mode?

    errors.add(:base, 'モードとカテゴリータイプが一致していません。')
  end

  # 次の通知の実行日時を計算する
  def next_run_at
    now = Time.zone.now
    # 指定された時刻でDateTimeを作成する
    target_datetime = create_target_datetime(now)

    # 通知設定に従って次の実行日時を計算する
    # 計算した日時が過去になってしまった場合は設定に従って先送りする
    if on_weekday.present?
      target_datetime = calculate_notification_date_for_weekday(target_datetime)
    elsif interval_days.present?
      target_datetime = calculate_notification_date_by_interval(target_datetime)
    end

    target_datetime
  end

  private

  def default_mode?
    mode == 'default'
  end

  # folderモードが正しいかどうかを判定
  def folder_mode?
    folder_only? && category_type == 'Folder'
  end

  # tagモードが正しいかどうかを判定
  def tag_mode?
    tag_only? && category_type == 'Tag'
  end

  def create_target_datetime(now)
    scheduled_time.change(
      year: now.year,
      month: now.month,
      day: now.day
    )
  end

  def calculate_notification_date_for_weekday(target_datetime)
    days_until_target = ((on_weekday_before_type_cast - target_datetime.wday) % 7).days
    target_datetime += days_until_target
    target_datetime += 7.days while target_datetime.past?
    target_datetime
  end

  def calculate_notification_date_by_interval(target_datetime)
    target_datetime += interval_days.days
    target_datetime += interval_days.days while target_datetime.past?
    target_datetime
  end
end
