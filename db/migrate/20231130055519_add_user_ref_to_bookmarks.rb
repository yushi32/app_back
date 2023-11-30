class AddUserRefToBookmarks < ActiveRecord::Migration[7.0]
  def change
    change_column_null :bookmarks, :user_id, false
    add_foreign_key :bookmarks, :users
  end
end
