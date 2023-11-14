class CreateBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :bookmarks do |t|
      t.string :url, null: false
      t.string :title, null: false
      t.string :thumbnail
      t.string :caption, limit: 140
      t.integer :status, default: 0
      t.boolean :recommendable, default: false
      t.references :user

      t.timestamps
    end
  end
end
