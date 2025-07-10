class AddForeignKeysToUserNotifications < ActiveRecord::Migration[6.1]
  def up
    unless foreign_key_exists?(:user_notifications, name: 'fk_user_notifications_users')
      add_foreign_key :user_notifications, :users, column: :user_id, name: 'fk_user_notifications_users'
    end

    add_foreign_key :user_notifications, :notifications, column: :notification_id, name: 'fk_user_notifications_notifications', on_delete: :cascade
  end

  def down
    remove_foreign_key :user_notifications, name: 'fk_user_notifications_users'
    remove_foreign_key :user_notifications, name: 'fk_user_notifications_notifications'
  end
end
