class RenameColumnCommissionJournalHeaderIdToCommissionJournalIdOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    rename_column :payrolls, :commission_journal_header_id, :commission_journal_id
  end
end
