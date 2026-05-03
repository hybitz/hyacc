class Insert2110OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    parent = Account.find_by_code(ACCOUNT_CODE_FIXED_ASSET)

    a = Account.find_by_code(ACCOUNT_CODE_TANGIBLE_FIXED_ASSETS)
    a ||= Account.new(code: ACCOUNT_CODE_TANGIBLE_FIXED_ASSETS)
    a.name = '有形固定資産'
    a.dc_type = parent.dc_type
    a.account_type = parent.account_type
    a.display_order = 0
    a.parent_id = parent.id
    a.journalizable = false
    a.trade_type = TRADE_TYPE_EXTERNAL
    a.is_settlement_report_account = true
    a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
    a.tax_type = parent.tax_type
    a.depreciable = false
    a.depreciation_method = nil
    a.system_required = true
    a.deleted = false
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_TANGIBLE_FIXED_ASSETS)
    return unless a

    a.deleted = true
    a.save!
  end
end
