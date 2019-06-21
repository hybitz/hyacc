class RemoveColumnYmdEndOnRents < ActiveRecord::Migration[5.2]
  def change
    remove_column :rents, :ymd_end, :date
  end
end
