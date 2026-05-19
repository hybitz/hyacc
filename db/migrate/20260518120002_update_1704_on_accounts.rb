class Update1704OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    a = Account.find_by_code('1704')
    return unless a

    # 短期貸付金（株主）1704 を廃止（save! では補助科目解決に失敗するため update_columns）
    a.update_columns(
      deleted: true,
      journalizable: false,
      sub_account_type: SUB_ACCOUNT_TYPE_NORMAL
    )
  end

  def down
  end
end
