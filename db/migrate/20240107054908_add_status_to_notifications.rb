class AddStatusToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :status, :boolean, default: true, null: false
  end
end
