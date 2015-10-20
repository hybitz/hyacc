class RenameColumnCreatedOnToCreatedAtOnJournalHeaders < ActiveRecord::Migration
  def change
    rename_column :journal_headers, :created_on, :created_at
  end
end
