class RemoveColumnIsAllocatedCostOnJournalDetails < ActiveRecord::Migration[5.1]
  def change
    remove_column :journal_details, :is_allocated_cost, :boolean, null: false, default: false
  end
end
