class RemoveColumnPayJournalIdOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    remove_column :payrolls, :pay_journal_id, :integer
  end
end
