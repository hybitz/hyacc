class Update1704OnAccounts < ActiveRecord::Migration[8.1]
  def up
    a = Account.find_by_code('1704')
    return unless a

    # 短期貸付金（株主）1704 を論理削除（save! では補助科目解決に失敗する）
    a.update_column(:deleted, true)
  end

  def down
  end
end
