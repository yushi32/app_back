class Tag < ApplicationRecord
  validates :name, presence: true
  
  has_many :user_tags, dependent: :destroy
  has_many :users, through: :user_tags
  has_many :bookmark_tags
  has_many :bookmarks, through: :bookmark_tags
  has_many :notifications, as: :category, dependent: :nullify
end
