class Insert1882OnAccounts < ActiveRecord::Migration[5.2]
  include HyaccConst

  def up
    parent = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_PAYMENT)

    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_PAYMENT_EMPLOYEE)
    a ||= Account.new(code: ACCOUNT_CODE_TEMPORARY_PAYMENT_EMPLOYEE)
    a.name = '仮払金（従業員）'
    a.dc_type = parent.dc_type
    a.account_type = parent.account_type
    a.display_order = 1
    a.parent_id = parent.id
    a.path = parent.path + '/' + ACCOUNT_CODE_TEMPORARY_PAYMENT_EMPLOYEE
    a.journalizable = true
    a.trade_type = TRADE_TYPE_EXTERNAL
    a.is_settlement_report_account = false
    a.sub_account_type = SUB_ACCOUNT_TYPE_EMPLOYEE
    a.tax_type = parent.tax_type
    a.system_required = true
    a.deleted = false
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_PAYMENT_EMPLOYEE)
    a.deleted = true
    a.save!
  end
end
