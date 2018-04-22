class AddColumnAllocatedOnJournalDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :journal_details, :allocated, :boolean, null: false, default: false
  end
end
