# buying_or_selling から securities_transaction_type へのリネーム移行に伴い、
# 旧カラムを NULL 許可にする。旧カラム削除時に本変更は不要となる。
class AllowNullBuyingOrSellingOnInvestments < ActiveRecord::Migration[8.1]
  def change
    change_column_null(:investments, :buying_or_selling, true)
  end
end
