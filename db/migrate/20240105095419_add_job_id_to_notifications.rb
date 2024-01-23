class AddJobIdToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :job_id, :string
  end
end
