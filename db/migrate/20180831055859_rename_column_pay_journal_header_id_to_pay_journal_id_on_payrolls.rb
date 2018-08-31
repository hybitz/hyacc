class RenameColumnPayJournalHeaderIdToPayJournalIdOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    rename_column :payrolls, :pay_journal_header_id, :pay_journal_id
  end
end
