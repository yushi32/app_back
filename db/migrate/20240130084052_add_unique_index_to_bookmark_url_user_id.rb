class AddUniqueIndexToBookmarkUrlUserId < ActiveRecord::Migration[7.0]
  def change
    add_index :bookmarks, [:url, :user_id], unique: true
  end
end
