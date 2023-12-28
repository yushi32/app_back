class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :category, polymorphic: true

  validates :start_date, presence: true
  validates :scheduled_time, presence: true
  validates :mode, presence: true

  enum on_weekday: { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }
  enum mode: { default: 0, folder_only: 1, tag_only: 2 }
end
