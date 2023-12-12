class Folder < ApplicationRecord
  validates :name, presence: true
  validates :position, presence: true, numericality: { only_float: true }

  belongs_to :user
  belongs_to :parent, class_name: :Folder, optional: true
  has_many :children, class_name: :Folder, foreign_key: :parent_id
  has_many :bookmarks

  scope :root, -> { where(parent_id: nil) }

  def set_position(folder_count)
    self.position = 65535.0 * (folder_count)
  end
end
