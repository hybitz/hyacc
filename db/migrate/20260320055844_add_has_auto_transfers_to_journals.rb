class AddHasAutoTransfersToJournals < ActiveRecord::Migration[8.1]
  def change
    add_column :journals, :has_auto_transfers, :boolean, default: nil, null: true
  end
end
