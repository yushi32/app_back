class Folder < ApplicationRecord
  validates :name, presence: true

  belongs_to :user
  belongs_to :parent, class_name: :Folder, optional: true
  has_many :children, class_name: :Folder, foreign_key: :parent_id
end
