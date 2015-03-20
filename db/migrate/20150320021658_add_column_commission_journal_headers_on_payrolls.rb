class AddColumnCommissionJournalHeadersOnPayrolls < ActiveRecord::Migration
  def change
    add_column :payrolls, :commission_journal_header_id, :integer
  end
end
