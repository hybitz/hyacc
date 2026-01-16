class InsertOrUpdate8741OnAccounts < ActiveRecord::Migration[7.2]
  include HyaccConst

  def up
    parent = Account.find_by_code( ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE)

    a = Account.find_by_code(ACCOUNT_CODE_DONATION)
    a ||= Account.new(code: ACCOUNT_CODE_DONATION)
    
    if a.new_record?
      a.name = '寄付金'
      a.dc_type = parent.dc_type
      a.account_type = parent.account_type
      a.parent_id = parent.id
      a.path = parent.path + '/' + ACCOUNT_CODE_DONATION
      a.journalizable = true
      a.trade_type = TRADE_TYPE_EXTERNAL
      a.is_settlement_report_account = true
      a.tax_type = parent.tax_type
      a.system_required = false
      a.deleted = false
    end

    a.sub_account_type = SUB_ACCOUNT_TYPE_DONATION
    a.sub_account_editable = true
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_DONATION)

    a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
    a.save!
  end
end

