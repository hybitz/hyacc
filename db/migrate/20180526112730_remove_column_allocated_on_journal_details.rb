class RemoveColumnAllocatedOnJournalDetails < ActiveRecord::Migration[5.2]
  def change
    remove_column :journal_details, :allocated, :boolean, null: false, default: false
  end
end
