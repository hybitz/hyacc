class RemoveColumnSharesOnJournalDetails < ActiveRecord::Migration
  def up
    remove_column :journal_details, :shares
  end
  def down
    add_column :journal_details, :shares, :integer
  end
end
