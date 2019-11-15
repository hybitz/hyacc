class AddColumnQualificationAllowanceOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :qualification_allowance, :integer
  end
end
