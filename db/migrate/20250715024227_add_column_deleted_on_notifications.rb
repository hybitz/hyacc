class AddColumnDeletedOnNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :deleted, :boolean, null: false, default: false
  end
end
