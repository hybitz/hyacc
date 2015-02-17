class AddIndexPayrollsYmAndEmployeeId < ActiveRecord::Migration
  def self.up
    add_index :payrolls, ['ym', 'employee_id'], :name=>"index_payrolls_ym_and_employee_id", :unique=>true
  end

  def self.down
    remove_index :payrolls, :name=>"index_payrolls_ym_and_employee_id"
  end
end
