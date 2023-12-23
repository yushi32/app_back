class AddNotNullConstraintToBookmarkTags < ActiveRecord::Migration[7.0]
  def change
    change_column_null :bookmark_tags, :bookmark_id, false
    change_column_null :bookmark_tags, :tag_id, false
  end
end
