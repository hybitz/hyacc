# どちらか一方は必ず値が入るように CHECK 制約を追加する。旧カラム削除時に本制約も解除する。
class AddCheckConstraintBuyingOrSellingOrSecuritiesTransactionTypeOnInvestments < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :investments,
      "buying_or_selling IS NOT NULL OR securities_transaction_type IS NOT NULL",
      name: "chk_investments_transaction_type"
  end
end
