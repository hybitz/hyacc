class Insert2704OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    parent = Account.find_by_code(ACCOUNT_CODE_LONG_TERM_LOAN)

    a = Account.find_by_code('2704')
    a ||= Account.new(code: '2704')
    a.name = '長期貸付金（株主）'
    a.dc_type = parent.dc_type
    a.account_type = parent.account_type
    a.display_order = 3
    a.parent_id = parent.id
    a.path = parent.path + '/2704'
    a.journalizable = true
    a.trade_type = TRADE_TYPE_EXTERNAL
    a.is_settlement_report_account = false
    a.sub_account_type = 17
    a.tax_type = parent.tax_type
    a.system_required = false
    a.deleted = false
    # 長期貸付金（株主）2704 はのちに廃止する。save! では補助科目解決に失敗するため検証を省略
    a.save!(validate: false)
  end

  def down
    a = Account.find_by_code('2704')
    return unless a

    # 長期貸付金（株主）2704 を論理削除（save! では補助科目解決に失敗する）
    a.update_column(:deleted, true)
  end
end
