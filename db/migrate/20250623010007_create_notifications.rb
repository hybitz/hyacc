class CreateNotifications < ActiveRecord::Migration[6.1]
  def up
    create_table :notifications, id: :integer do |t|
      t.string :message

      t.timestamps
    end
  end

  def down
    drop_table :notifications
  end
end
