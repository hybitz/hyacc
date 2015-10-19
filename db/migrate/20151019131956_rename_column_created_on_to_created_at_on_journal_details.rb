class RenameColumnCreatedOnToCreatedAtOnJournalDetails < ActiveRecord::Migration
  def change
    rename_column :journal_details, :created_on, :created_at
  end
end
