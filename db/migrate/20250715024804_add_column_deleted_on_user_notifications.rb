class AddColumnDeletedOnUserNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :user_notifications, :deleted, :boolean, null: false, default: false
  end
end
