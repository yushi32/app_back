class Bookmark < ApplicationRecord
  validates :url, presence: true
  validates :title, presence: true
  validates :states, presence: true
  validates :caption, length: { maximum: 140 }

  belongs_to :user

  enum status: { unnotified:0, notified:1, read:2 }
end
