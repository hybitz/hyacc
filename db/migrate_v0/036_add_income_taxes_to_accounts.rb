# -*- encoding : utf-8 -*-
class AddIncomeTaxesToAccounts < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    expense = Account.find_by_code( ACCOUNT_CODE_EXPENSE )
    income_taxes = Account.new
    income_taxes.code = ACCOUNT_CODE_CORPORATE_TAXES
    income_taxes.name = '法人税等'
    income_taxes.account_type = expense.account_type
    income_taxes.dc_type = expense.dc_type
    income_taxes.parent_id = expense.id
    income_taxes.system_required = true
    income_taxes.display_order = expense.children.size + 1
    income_taxes.save
    
    debt = Account.find_by_code( ACCOUNT_CODE_DEBT )
    unpaid_income_taxes = Account.new
    unpaid_income_taxes.code = '3185'
    unpaid_income_taxes.name = '未払法人税等'
    unpaid_income_taxes.account_type = debt.account_type
    unpaid_income_taxes.dc_type = debt.dc_type
    unpaid_income_taxes.parent_id = debt.id
    unpaid_income_taxes.system_required = false
    unpaid_income_taxes.display_order = debt.children.size + 1
    unpaid_income_taxes.save
  end

  def self.down
    Account.find_by_code( ACCOUNT_CODE_CORPORATE_TAXES ).destroy
    Account.find_by_code('3185').destroy
  end
end
