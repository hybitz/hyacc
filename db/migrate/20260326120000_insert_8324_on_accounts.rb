class Insert8324OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    parent = Account.find_by_code(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE)

    a = Account.find_by_code(ACCOUNT_CODE_EXECUTIVE_RETIREMENT)
    a ||= Account.new(code: ACCOUNT_CODE_EXECUTIVE_RETIREMENT)
    a.name = '役員退職金'
    a.dc_type = parent.dc_type
    a.account_type = parent.account_type
    a.display_order = 29
    a.parent_id = parent.id
    a.path = parent.path + '/' + ACCOUNT_CODE_EXECUTIVE_RETIREMENT
    a.journalizable = true
    a.trade_type = TRADE_TYPE_EXTERNAL
    a.is_settlement_report_account = true
    a.sub_account_type = SUB_ACCOUNT_TYPE_EMPLOYEE
    a.tax_type = parent.tax_type
    a.company_only = true
    a.system_required = true
    a.deleted = false
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_EXECUTIVE_RETIREMENT)
    return unless a

    a.deleted = true
    a.save!
  end
end
