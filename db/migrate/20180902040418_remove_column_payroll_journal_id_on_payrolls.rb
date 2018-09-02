class RemoveColumnPayrollJournalIdOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    remove_column :payrolls, :payroll_journal_id, :integer
  end
end
