class AddIndexToUserNotifications < ActiveRecord::Migration[6.1]
  def up
    add_index :user_notifications, [:user_id, :notification_id], unique: true, name: 'index_user_notifications_on_user_id_and_notification_id'
  end

  def down
    remove_index :user_notifications, name: 'index_user_notifications_on_user_id_and_notification_id'
  end
end