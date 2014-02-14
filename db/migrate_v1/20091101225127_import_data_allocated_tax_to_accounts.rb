# -*- encoding : utf-8 -*-
class ImportDataAllocatedTaxToAccounts < ActiveRecord::Migration
  include HyaccConstants
  def self.up
    count = Account.count
    a = Account.new
    a.code = ACCOUNT_CODE_HEAD_OFFICE_TAXES
    a.name = '法人税等配賦'
    a.dc_type = DC_TYPE_DEBIT
    a.account_type = ACCOUNT_TYPE_EXPENSE
    a.system_required = true
    a.trade_type = TRADE_TYPE_INTERNAL
    a.tax_type = TAX_TYPE_NONTAXABLE
    a.parent_id = Account.find_by_code(ACCOUNT_CODE_EXPENSE).id
    a.display_order =count + 1
    a.save
    sa = SubAccount.new( :code => '102', :name => 'ICHY' )
    sa.account = a
    sa.save
    
    sa = SubAccount.new( :code => '103', :name => 'HIRO' )
    sa.account = a
    sa.save
    
    b = Account.new
    b.code = ACCOUNT_CODE_HEAD_OFFICE_TAXES_SHARE
    b.name = '法人税等負担'
    b.dc_type = DC_TYPE_DEBIT
    b.account_type = ACCOUNT_TYPE_EXPENSE
    b.system_required = true
    b.trade_type = TRADE_TYPE_INTERNAL
    b.tax_type = TAX_TYPE_NONTAXABLE
    b.parent_id = Account.find_by_code(ACCOUNT_CODE_EXPENSE).id
    b.display_order =count + 2
    b.save
  end

  def self.down
    Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_TAXES).destroy
    Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_TAXES_SHARE).destroy
  end
end
