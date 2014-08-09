class AddColumnDeletedOnJournalHeaders < ActiveRecord::Migration
  def up
    add_column :journal_headers, :deleted, :boolean, :null => false, :default => false
  end

  def down
    remove_column :journal_headers, :deleted
  end
end
