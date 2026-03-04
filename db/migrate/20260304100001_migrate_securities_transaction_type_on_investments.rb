class MigrateSecuritiesTransactionTypeOnInvestments < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL.squish
      UPDATE investments
      SET securities_transaction_type = buying_or_selling
      WHERE securities_transaction_type IS NULL
    SQL
  end

  def down
    execute <<-SQL.squish
      UPDATE investments
      SET securities_transaction_type = NULL
      WHERE securities_transaction_type IS NOT NULL
    SQL
  end
end
