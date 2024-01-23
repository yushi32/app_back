class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.datetime :start_date, null: false
      t.time :scheduled_time, null: false
      t.integer :interval_days
      t.integer :on_weekday
      t.integer :mode, default: 0
      t.references :user, null: false, foreign_key: true
      t.references :category, polymorphic: true

      t.timestamps
    end
  end
end
