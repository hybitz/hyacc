class AddColumnCompanyIdOnBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :company_id, :integer, null: false
  end
end
