class AddFolderIdToBookmarks < ActiveRecord::Migration[7.0]
  def change
    add_reference :bookmarks, :folder, null: true, foreign_key: true
  end
end
