class AddIndexToUserNotifications < ActiveRecord::Migration[6.1]
  def up
    return unless table_exists?(:user_notifications)

    unless index_exists?(:user_notifications, [:user_id, :notification_id], unique: true, name: 'index_user_notifications_on_user_id_and_notification_id')
      add_index :user_notifications, [:user_id, :notification_id], unique: true, name: 'index_user_notifications_on_user_id_and_notification_id'
    end
  end

  def down
    return unless table_exists?(:user_notifications)

    if index_exists?(:user_notifications, name: 'index_user_notifications_on_user_id_and_notification_id')
      remove_index :user_notifications, name: 'index_user_notifications_on_user_id_and_notification_id'
    end
  end
end