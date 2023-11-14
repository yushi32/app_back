class User < ApplicationRecord
  validates :name,  presence: true
  validates :uid,   presence: true, uniqueness: true

  has_many :bookmarks, dependent: :destroy

  def self.find_or_create_user(user_info)
    user = User.find_by(uid: user_info[:uid])
    return user if user

    User.create!(uid: user_info[:uid], name: user_info[:name])
  end
end