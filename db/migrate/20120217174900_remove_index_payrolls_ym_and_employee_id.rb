class RemoveIndexPayrollsYmAndEmployeeId < ActiveRecord::Migration
  def self.up
    remove_index :payrolls, :name=>"index_payrolls_ym_and_employee_id"
  end

  def self.down
    add_index :payrolls, ['ym', 'employee_id'], :name=>"index_payrolls_ym_and_employee_id", :unique=>true
  end
end
