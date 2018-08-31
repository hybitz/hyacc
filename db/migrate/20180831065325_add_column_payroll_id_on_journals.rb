class AddColumnPayrollIdOnJournals < ActiveRecord::Migration[5.2]
  def change
    add_column :journals, :payroll_id, :integer
  end
end
