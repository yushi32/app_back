class BookmarkTag < ApplicationRecord
  belongs_to :bookmark
  belongs_to :tag

  validates :bookmark_id, uniqueness: { scope: :tag_id }
end
