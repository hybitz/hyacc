class RemoveCascadeFromUserNotificationsForeignKey < ActiveRecord::Migration[6.1]
  def up
    if foreign_key_exists?(:user_notifications, name: 'fk_user_notifications_notifications')
      remove_foreign_key :user_notifications, name: 'fk_user_notifications_notifications'
    end
    add_foreign_key :user_notifications, :notifications, column: :notification_id, name: 'fk_user_notifications_notifications'
  end

  def down
    if foreign_key_exists?(:user_notifications, name: 'fk_user_notifications_notifications')
      remove_foreign_key :user_notifications, name: 'fk_user_notifications_notifications'
    end
    add_foreign_key :user_notifications, :notifications, column: :notification_id, name: 'fk_user_notifications_notifications', on_delete: :cascade
  end
end
