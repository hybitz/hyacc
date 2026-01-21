class RemoveSubAccountIdFromAssets < ActiveRecord::Migration[7.2]
  def change
    remove_column :assets, :sub_account_id, :integer
  end
end
