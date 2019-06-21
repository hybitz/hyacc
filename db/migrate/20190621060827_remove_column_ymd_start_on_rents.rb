class RemoveColumnYmdStartOnRents < ActiveRecord::Migration[5.2]
  def change
    remove_column :rents, :ymd_start, :integer, null: false
  end
end
