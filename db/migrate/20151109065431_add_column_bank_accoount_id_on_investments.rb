class AddColumnBankAccoountIdOnInvestments < ActiveRecord::Migration
  def change
    add_column :investments, :bank_account_id, :integer, :null => false
  end
end
