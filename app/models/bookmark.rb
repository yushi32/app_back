class Bookmark < ApplicationRecord
  validates :url, presence: true
  validates :title, presence: true
  validates :status, presence: true
  validates :caption, length: { maximum: 140 }

  belongs_to :user
  belongs_to :folder, optional: true
  has_many :bookmark_tags, dependent: :destroy
  has_many :tags, through: :bookmark_tags

  enum status: { unnotified:0, notified:1, read:2 }

  def save_with_tags(tag_name)
    if tag_name.present?
      new_tag = Tag.find_or_create_by(name: tag_name)
      self.tags << new_tag
    end
    save!
    true
  rescue StandardError
    false
  end
end
