class Insert1700OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    parent = Account.find_by_code(ACCOUNT_CODE_CURRENT_ASSETS)

    a = Account.find_by_code(ACCOUNT_CODE_SHORT_TERM_LOAN)
    a ||= Account.new(code: ACCOUNT_CODE_SHORT_TERM_LOAN)
    a.name = '短期貸付金'
    a.dc_type = parent.dc_type
    a.account_type = parent.account_type
    a.display_order = 9
    a.parent_id = parent.id
    a.path = parent.path + '/' + ACCOUNT_CODE_SHORT_TERM_LOAN
    a.journalizable = true
    a.trade_type = TRADE_TYPE_EXTERNAL
    a.is_settlement_report_account = true
    a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
    a.tax_type = parent.tax_type
    a.system_required = true
    a.deleted = false
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_SHORT_TERM_LOAN)
    return unless a

    a.deleted = true
    a.save!
  end
end
