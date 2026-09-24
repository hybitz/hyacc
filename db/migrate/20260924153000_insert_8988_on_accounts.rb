class Insert8988OnAccounts < ActiveRecord::Migration[8.1]
  include HyaccConst

  def up
    parent = Account.find_by_code(ACCOUNT_CODE_EXPENSE)

    a = Account.find_by_code(ACCOUNT_CODE_ALLOCATED_TAXES)
    a ||= Account.new(code: ACCOUNT_CODE_ALLOCATED_TAXES)
    a.name = '法人税等配賦'
    a.dc_type = parent.dc_type
    a.account_type = parent.account_type
    a.display_order = 5
    a.parent_id = parent.id
    a.path = parent.path + '/' + ACCOUNT_CODE_ALLOCATED_TAXES
    a.journalizable = true
    a.trade_type = TRADE_TYPE_INTERNAL
    a.is_settlement_report_account = true
    a.sub_account_type = SUB_ACCOUNT_TYPE_BRANCH
    a.tax_type = parent.tax_type
    a.company_only = true
    a.system_required = true
    a.deleted = false
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_ALLOCATED_TAXES)
    return unless a

    a.deleted = true
    a.save!
  end
end
