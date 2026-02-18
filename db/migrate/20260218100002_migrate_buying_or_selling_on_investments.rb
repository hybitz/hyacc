class MigrateBuyingOrSellingOnInvestments < ActiveRecord::Migration[7.2]
  def up
    # 売却として負数で保存されている既存レコードを、正数 + buying_or_selling=0 に変換する。
    # 冪等のため、trading_value < 0 または shares < 0 の行のみ更新する。
    execute <<-SQL.squish
      UPDATE investments
      SET buying_or_selling = 0,
          shares = ABS(shares),
          trading_value = ABS(trading_value)
      WHERE trading_value < 0 OR shares < 0
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
