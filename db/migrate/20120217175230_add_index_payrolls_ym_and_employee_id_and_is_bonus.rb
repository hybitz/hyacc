class AddIndexPayrollsYmAndEmployeeIdAndIsBonus < ActiveRecord::Migration
  def self.up
    add_index :payrolls, ['ym', 'employee_id', 'is_bonus'], :name=>"index_payrolls_ym_and_employee_id_and_is_bonus", :unique=>true
    p1 = Payroll.new(:ym=>201201, :payroll_journal_header_id=>14247 ,:pay_journal_header_id=>14250, :employee_id=>2, :is_bonus=>true)
    p2 = Payroll.new(:ym=>201201, :payroll_journal_header_id=>14248, :pay_journal_header_id=>14249, :employee_id=>1, :is_bonus=>true)
    p1.save!
    p2.save!
  end

  def self.down
    remove_index :payrolls, :name=>"index_payrolls_ym_and_employee_id_and_is_bonus"
  end
end
