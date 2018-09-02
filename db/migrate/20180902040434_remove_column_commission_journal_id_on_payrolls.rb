class RemoveColumnCommissionJournalIdOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    remove_column :payrolls, :commission_journal_id, :integer
  end
end
