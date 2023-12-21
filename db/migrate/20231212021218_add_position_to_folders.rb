class AddPositionToFolders < ActiveRecord::Migration[7.0]
  def up
    add_column :folders, :position, :float
    
    User.find_each do |user|
      user.folders.order(:id).each_with_index do |folder, index|
        folder.update_columns(position: (index + 1) * 65535.0)
      end
    end

    change_column_null :folders, :position, false
  end

  def down
    remove_column :folders, :position
  end
end
