class RenameCaptionToNoteInBookmarks < ActiveRecord::Migration[7.0]
  def change
    rename_column :bookmarks, :caption, :note
  end
end
