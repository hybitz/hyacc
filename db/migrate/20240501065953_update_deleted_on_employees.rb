class UpdateDeletedOnEmployees < ActiveRecord::Migration[5.2]
  def change
    Employee.where(disabled: true).update_all(['deleted = ?', false])
  end
end
