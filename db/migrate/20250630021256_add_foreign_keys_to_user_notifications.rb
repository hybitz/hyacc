class AddForeignKeysToUserNotifications < ActiveRecord::Migration[6.1]
  def up
    return unless table_exists?(:user_notifications)

    unless foreign_key_exists?(:user_notifications, name: 'fk_user_notifications_users')
      add_foreign_key :user_notifications, :users, column: :user_id, name: 'fk_user_notifications_users'
    end

    unless foreign_key_exists?(:user_notifications, name: 'fk_user_notifications_notifications')
      add_foreign_key :user_notifications, :notifications, column: :notification_id, name: 'fk_user_notifications_notifications', on_delete: :cascade
    end
  end

  def down
    return unless table_exists?(:user_notifications)

    if foreign_key_exists?(:user_notifications, name: 'fk_user_notifications_users')
      remove_foreign_key :user_notifications, name: 'fk_user_notifications_users'
    end

    if foreign_key_exists?(:user_notifications, name: 'fk_user_notifications_notifications')
      remove_foreign_key :user_notifications, name: 'fk_user_notifications_notifications'
    end
  end
end
