class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :category, polymorphic: true

  validates :start_date, presence: true
  validates :scheduled_time, presence: true
  validates :mode, presence: true

  validate :valid_mode_matches_category_type

  enum on_weekday: { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }
  enum mode: { default: 0, folder_only: 1, tag_only: 2 }

  def valid_mode_matches_category_type
    return if defult_mode? || folder_mode? || tag_mode?

    errors.add(:base, 'モードとカテゴリータイプが一致していません。')
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
