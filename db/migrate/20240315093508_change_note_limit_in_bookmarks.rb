class ChangeNoteLimitInBookmarks < ActiveRecord::Migration[7.0]
  def up
    change_column :bookmarks, :note, :string, limit: 500
  end

  def down
    change_column :bookmarks, :note, :string, limit: 140
  end
end
