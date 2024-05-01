class UpdateDisabledOnEmployees < ActiveRecord::Migration[5.2]
  def change
    Employee.where(deleted: true).update_all(['disabled = ?', true])
  end
end
