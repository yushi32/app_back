class Folder < ApplicationRecord
  validates :name, presence: true
  validates :position, presence: true, numericality: { only_float: true }

  belongs_to :user
  belongs_to :parent, class_name: :Folder, optional: true
  has_many :children, class_name: :Folder, foreign_key: :parent_id
  has_many :bookmarks, dependent: :nullify

  scope :root, -> { where(parent_id: nil) }

  def save_and_set_position(final_folder)
    self.position = final_folder.position + 65535.0
    save!
    true
  rescue StandardError
    false
  end
end
