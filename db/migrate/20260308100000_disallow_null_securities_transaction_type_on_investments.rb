class DisallowNullSecuritiesTransactionTypeOnInvestments < ActiveRecord::Migration[8.1]
  def change
    change_column_null(:investments, :securities_transaction_type, false)
  end
end
