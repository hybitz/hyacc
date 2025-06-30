class CreateUserNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :user_notifications, id: :integer do |t|
      t.integer :user_id, null: false
      t.integer :notification_id, null: false
      t.boolean :visible, default: true, null: false
      t.timestamps
    end
  end
end
