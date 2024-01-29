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

  scope :for_notification, -> {
    unnotified_ids = unnotified.pluck(:id)
    selected_ids = unnotified_ids.sample(3)
    where(id: selected_ids).order(id: :asc)
  }

  def save_with_tags(tag_name, current_user)
    ActiveRecord::Base.transaction do
      if tag_name.present?
        new_tag = Tag.find_or_create_by(name: tag_name)
        add_tag(new_tag) unless has_tag?(new_tag.id)

        current_user.add_tag(new_tag) unless current_user.has_tag?(new_tag.id)

      end
      save!
    end
    true
  rescue StandardError
    false
  end
  
  private
  
  def add_tag(tag)
    tags << tag
  end

  def has_tag?(tag_id)
    tags.exists?(id: tag_id)
  end
end
