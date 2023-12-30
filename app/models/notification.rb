class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :category, polymorphic: true, optional: true

  validates :start_date, presence: true
  validates :scheduled_time, presence: true
  validates :mode, presence: true

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
    target_datetime = scheduled_time.change(
      year: now.year, 
      month: now.month, 
      day: now.day
    )

    # 次に来る指定された曜日の日付を計算する
    days_until_target = ((on_weekday_before_type_cast - now.wday) % 7).days
    target_datetime = target_datetime + days_until_target

    # もし計算された日時が過去になる場合は、次の週の同じ曜日に変更する
    target_datetime += 7.days if target_datetime.past?

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
end
