class RenameColumnUpdatedOnToUpdatedAtOnJournalDetails < ActiveRecord::Migration
  def change
    rename_column :journal_details, :updated_on, :updated_at
  end
end
