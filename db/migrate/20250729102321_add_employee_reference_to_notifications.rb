class AddEmployeeReferenceToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_reference :notifications, :employee, null: true, foreign_key: true, type: :integer
  end
end
