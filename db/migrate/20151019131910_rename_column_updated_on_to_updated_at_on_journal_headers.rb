class RenameColumnUpdatedOnToUpdatedAtOnJournalHeaders < ActiveRecord::Migration
  def change
    rename_column :journal_headers, :updated_on, :updated_at
  end
end
