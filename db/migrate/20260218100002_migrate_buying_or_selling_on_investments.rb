class MigrateBuyingOrSellingOnInvestments < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL.squish
      UPDATE investments
      SET buying_or_selling = CASE WHEN trading_value < 0 OR shares < 0 THEN 0 ELSE 1 END,
          shares = ABS(shares),
          trading_value = ABS(trading_value)
    SQL
  end

  def down
    # 売却（buying_or_selling=0）のレコードを、従来の負数表現に戻す。
    execute <<-SQL.squish
      UPDATE investments
      SET shares = -shares,
          trading_value = -trading_value
      WHERE buying_or_selling = 0
    SQL
  end
end
