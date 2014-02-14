# -*- encoding : utf-8 -*-
class AddColumnTradeTypeToAccounts < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    add_column :accounts, "trade_type", :integer, :limit=>1, :null=>false, :default=>1

    # カラム情報を最新にする
    Account.reset_column_information
    
    assets = Account.find_by_code( ACCOUNT_CODE_ASSETS )
    
    a = Account.new
    a.code = ACCOUNT_CODE_BRANCH_OFFICE
    a.name = '支店勘定'
    a.account_type = ACCOUNT_TYPE_ASSET
    a.dc_type = DC_TYPE_DEBIT
    a.parent_id = 44
    a.system_required = true
    a.display_order = assets.children.size + 1
    a.trade_type = TRADE_TYPE_INTERNAL
    a.sub_accounts = []
    a.sub_accounts << SubAccount.new({:code=>'100', :name=>'ICHY'})
    a.sub_accounts << SubAccount.new({:code=>'200', :name=>'HIRO'})
    a.save
    
    capital = Account.find_by_code( ACCOUNT_CODE_CAPITAL )
    
    b = Account.new
    b.code = ACCOUNT_CODE_HEAD_OFFICE
    b.name = '本店勘定'
    b.account_type = ACCOUNT_TYPE_CAPITAL
    b.dc_type = DC_TYPE_CREDIT
    b.parent_id = 46
    b.system_required = true
    b.display_order = capital.children.size + 1
    b.trade_type = TRADE_TYPE_INTERNAL
    b.save
    
  end

  def self.down
    remove_column :accounts, "trade_type"

    # カラム情報を最新にする
    Account.reset_column_information
    
    Account.find_by_code( ACCOUNT_CODE_HEAD_OFFICE ).destroy
    Account.find_by_code( ACCOUNT_CODE_BRANCH_OFFICE ).destroy
  end
end
