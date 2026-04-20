class Insert1701OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    parent = Account.find_by_code(ACCOUNT_CODE_SHORT_TERM_LOAN)

    a = Account.find_by_code(ACCOUNT_CODE_SHORT_TERM_LOAN_EMPLOYEE)
    a ||= Account.new(code: ACCOUNT_CODE_SHORT_TERM_LOAN_EMPLOYEE)
    a.name = '短期貸付金（従業員）'
    a.dc_type = parent.dc_type
    a.account_type = parent.account_type
    a.display_order = 0
    a.parent_id = parent.id
    a.path = parent.path + '/' + ACCOUNT_CODE_SHORT_TERM_LOAN_EMPLOYEE
    a.journalizable = true
    a.trade_type = TRADE_TYPE_EXTERNAL
    a.is_settlement_report_account = false
    a.sub_account_type = SUB_ACCOUNT_TYPE_EMPLOYEE
    a.tax_type = parent.tax_type
    a.system_required = false
    a.deleted = false
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_SHORT_TERM_LOAN_EMPLOYEE)
    return unless a

    a.deleted = true
    a.save!
  end
end
