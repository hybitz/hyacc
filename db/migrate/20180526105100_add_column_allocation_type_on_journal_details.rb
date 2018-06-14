class AddColumnAllocationTypeOnJournalDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :journal_details, :allocation_type, :integer
  end
end
