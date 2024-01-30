class AddUniqueIndexToUserTagUserIdTagId < ActiveRecord::Migration[7.0]
  def change
    add_index :user_tags, [:user_id, :tag_id], unique: true
  end
end
