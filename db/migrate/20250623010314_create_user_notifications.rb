class CreateUserNotifications < ActiveRecord::Migration[6.1]
  def up
    create_table :user_notifications, id: :integer do |t|
      t.integer :user_id, null: false
      t.integer :notification_id, null: false
      t.boolean :visible, default: true, null: false

      t.timestamps
    end

    add_foreign_key :user_notifications, :users, column: :user_id
    add_foreign_key :user_notifications, :notifications, column: :notification_id, on_delete: :cascade

    add_index :user_notifications, [:user_id, :notification_id], unique: true
  end

  def down
    drop_table :user_notifications
  end
end
