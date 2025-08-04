class AddColumnYmOnNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :ym, :integer, null: true
  end
end
