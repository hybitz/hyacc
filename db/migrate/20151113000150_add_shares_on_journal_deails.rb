class AddSharesOnJournalDeails < ActiveRecord::Migration
  def change
    add_column :journal_details, :shares, :integer
  end
end
