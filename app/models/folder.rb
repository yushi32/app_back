class Folder < ApplicationRecord
  DEFAULT_POSITION_GAP = 65535.0

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_float: true }

  belongs_to :user
  belongs_to :parent, class_name: :Folder, optional: true
  has_many :children, class_name: :Folder, foreign_key: :parent_id, dependent: :nullify
  has_many :bookmarks, dependent: :nullify
  has_one :notification, as: :category, dependent: :nullify

  scope :root, -> { where(parent_id: nil) }

  def save_and_set_position(final_folder)
    self.position = final_folder ? final_folder.position + DEFAULT_POSITION_GAP : DEFAULT_POSITION_GAP
    save!
    true
  rescue StandardError
    false
  end
end
