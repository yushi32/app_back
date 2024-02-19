class User < ApplicationRecord
  validates :name,  presence: true
  validates :uid,   presence: true, uniqueness: true

  has_many :bookmarks, dependent: :destroy
  has_many :folders, dependent: :destroy
  has_many :user_tags, dependent: :destroy
  has_many :tags, through: :user_tags
  has_one :notification, dependent: :destroy

  def self.find_or_create_user(user_info)
    user = User.find_by(uid: user_info[:uid])
    return user if user

    User.create!(uid: user_info[:uid], name: user_info[:name])
  end

  def root_folders
    folders.includes(:children).root
  end

  def final_folder
    folders.order(position: :asc).last
  end

  def add_tag(tag)
    tags << tag
  end

  def tag_used?(tag_id)
    tags.exists?(id: tag_id)
  end
end
