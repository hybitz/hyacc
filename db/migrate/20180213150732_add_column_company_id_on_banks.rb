class AddColumnCompanyIdOnBanks < ActiveRecord::Migration[5.1]
  def change
    add_column :banks, :company_id, :integer, null: false
  end
end
