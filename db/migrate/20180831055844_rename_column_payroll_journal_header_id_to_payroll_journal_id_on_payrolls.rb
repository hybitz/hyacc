class RenameColumnPayrollJournalHeaderIdToPayrollJournalIdOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    rename_column :payrolls, :payroll_journal_header_id, :payroll_journal_id
  end
end
