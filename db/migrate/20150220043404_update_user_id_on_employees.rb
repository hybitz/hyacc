class UpdateUserIdOnEmployees < ActiveRecord::Migration
  def up
    User.find_each do |u|
      next unless u.employee_id.present?

      e = Employee.find(u.employee_id)
      raise 'update column error' unless e.update_column(:user_id, u.id)
    end
  end
  
  def down
  end
end
