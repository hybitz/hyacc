# -*- encoding : utf-8 -*-
class AddColumnIsTradeAccountPayableToAccounts < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    add_column :accounts, :is_trade_account_payable, :integer, :limit=>1, :null=>false, :default=>false
    
    # カラム情報を最新にする
    Account.reset_column_information
    
    Account.update_all("is_trade_account_payable=1", "code in ('3141', '3171', '3172', '3183')")
    Account.update_all("sub_account_type=#{SUB_ACCOUNT_TYPE_ORDER_PLACEMENT}", "code in ('3141')")
  end

  def self.down
    remove_column :accounts, :is_trade_account_payable
    
    # カラム情報を最新にする
    Account.reset_column_information
    
    Account.update_all("sub_account_type=#{SUB_ACCOUNT_TYPE_NORMAL}", "code in ('3141')")
  end
end
