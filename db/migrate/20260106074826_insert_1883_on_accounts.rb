class Insert1883OnAccounts < ActiveRecord::Migration[7.2]
  include HyaccConst

  def up
    parent = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_PAYMENT)

    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_PAYMENT_CUSTOMER)
    a ||= Account.new(code: ACCOUNT_CODE_TEMPORARY_PAYMENT_CUSTOMER)
    a.name = '仮払金（取引先）'
    a.dc_type = parent.dc_type
    a.account_type = parent.account_type
    a.display_order = 2
    a.parent_id = parent.id
    a.path = parent.path + '/' + ACCOUNT_CODE_TEMPORARY_PAYMENT_CUSTOMER
    a.journalizable = true
    a.trade_type = TRADE_TYPE_EXTERNAL
    a.is_settlement_report_account = false
    a.is_temporary_payment_account = true
    a.sub_account_type = SUB_ACCOUNT_TYPE_CUSTOMER
    a.tax_type = parent.tax_type
    a.system_required = true
    a.deleted = false
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_PAYMENT_CUSTOMER)
    a.deleted = true
    a.save!
  end
end
