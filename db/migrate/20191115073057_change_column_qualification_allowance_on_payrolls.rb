class ChangeColumnQualificationAllowanceOnPayrolls < ActiveRecord::Migration[5.2]
  def up
    Payroll.update_all(['qualification_allowance = ?', 0])
    change_column :payrolls, :qualification_allowance, :integer, null: false, default: 0
  end
  def down
  end
end
