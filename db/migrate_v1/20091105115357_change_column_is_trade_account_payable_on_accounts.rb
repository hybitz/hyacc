# -*- encoding : utf-8 -*-
class ChangeColumnIsTradeAccountPayableOnAccounts < ActiveRecord::Migration
  def self.up
    change_column :accounts, :is_trade_account_payable, :boolean, :null=>false, :default=>false
    
    # カラム情報を最新にする
    Account.reset_column_information
    
    Account.update_all(["is_trade_account_payable=?", true], "code in ('3141', '3171', '3172', '3183')")
  end

  def self.down
    change_column :accounts, :is_trade_account_payable, :integer, :limit=>1, :null=>false, :default=>false
    
    # カラム情報を最新にする
    Account.reset_column_information
    
    Account.update_all("is_trade_account_payable=1", "code in ('3141', '3171', '3172', '3183')")
  end
end
