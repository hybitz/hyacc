class RemoveColumnCompanyIdOnUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :company_id, :integer, default: 0, null: false
  end
end
