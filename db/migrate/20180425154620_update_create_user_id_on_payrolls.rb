class UpdateCreateUserIdOnPayrolls < ActiveRecord::Migration[5.1]
  def up
    Payroll.order('employee_id, ym').each do |p|
      u = p.employee.user
      unless u
        b = BranchEmployee.where(employee_id: p.employee_id, default_branch: true).first.branch.parent
        be = BranchEmployee.where(branch_id: b.id, default_branch: true).first
        u = be.employee.user
      end
      puts "#{p.ym}: #{p.employee.fullname} => #{u.employee.fullname}"
      p.update_column(:create_user_id, u.id)
    end
  end
  
  def down
  end
end
