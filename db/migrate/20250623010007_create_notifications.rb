class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications, id: :integer do |t|
      t.string :message
      t.timestamps
    end
  end
end
