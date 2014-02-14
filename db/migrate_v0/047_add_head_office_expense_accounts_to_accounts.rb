# -*- encoding : utf-8 -*-
class AddHeadOfficeExpenseAccountsToAccounts < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    count = Account.count
  
    head_office_cost = Account.new
    head_office_cost.code = ACCOUNT_CODE_HEAD_OFFICE_COST
    head_office_cost.name = '本社費用配賦'
    head_office_cost.dc_type = DC_TYPE_DEBIT
    head_office_cost.account_type = ACCOUNT_TYPE_EXPENSE
    head_office_cost.system_required = true
    head_office_cost.trade_type = TRADE_TYPE_INTERNAL
    head_office_cost.parent_id = Account.find_by_code(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE).id
    head_office_cost.display_order =count + 1
    head_office_cost.save
    
    head_office_cost_share = Account.new
    head_office_cost_share.code = ACCOUNT_CODE_HEAD_OFFICE_COST_SHARE
    head_office_cost_share.name = '本社費用負担'
    head_office_cost_share.dc_type = DC_TYPE_DEBIT
    head_office_cost_share.account_type = ACCOUNT_TYPE_EXPENSE
    head_office_cost_share.system_required = true
    head_office_cost_share.trade_type = TRADE_TYPE_INTERNAL
    head_office_cost_share.parent_id = Account.find_by_code(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE).id
    head_office_cost_share.display_order =count + 2
    head_office_cost_share.save
  end

  def self.down
    Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST).destroy
    Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST_SHARE).destroy
  end
end
