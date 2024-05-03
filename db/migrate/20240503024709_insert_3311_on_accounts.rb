class Insert3311OnAccounts < ActiveRecord::Migration[5.2]
  include HyaccConst

  def up
    parent = Account.find_by_code(ACCOUNT_CODE_SUSPENSE_RECEIPT)

    a = Account.find_by_code(ACCOUNT_CODE_SUSPENSE_RECEIPT_EMPLOYEE)
    a ||= Account.new(code: ACCOUNT_CODE_SUSPENSE_RECEIPT_EMPLOYEE)
    a.name = '仮受金（従業員）'
    a.dc_type = parent.dc_type
    a.account_type = parent.account_type
    a.display_order = 1
    a.parent_id = parent.id
    a.path = parent.path + '/' + ACCOUNT_CODE_SUSPENSE_RECEIPT_EMPLOYEE
    a.journalizable = true
    a.trade_type = TRADE_TYPE_EXTERNAL
    a.is_settlement_report_account = false
    a.sub_account_type = SUB_ACCOUNT_TYPE_EMPLOYEE
    a.sub_account_editable = false
    a.tax_type = parent.tax_type
    a.system_required = true
    a.deleted = false
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_SUSPENSE_RECEIPT_EMPLOYEE)
    a.deleted = true
    a.save!
  end
end
