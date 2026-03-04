class AddSecuritiesTransactionTypeToInvestments < ActiveRecord::Migration[8.1]
  def change
    add_column :investments, :securities_transaction_type, :integer
  end
end
