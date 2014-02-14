# -*- encoding : utf-8 -*-
class AddColumnSystemRequiredToAccounts < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    add_column :accounts, "system_required", :boolean, :null => false, :default => false
    
    # カラム情報を最新にする
    Account.reset_column_information
    
    # 既存レコードを更新
    [ ACCOUNT_CODE_CASH,
      ACCOUNT_CODE_DEBT_TO_OWNER,
      ACCOUNT_CODE_PAID_FEE,
      ACCOUNT_CODE_SMALL_CASH,
      ACCOUNT_CODE_TEMP_PAY_TAX,
      ACCOUNT_CODE_VARIOUS,
      ACCOUNT_CODE_ORDINARY_DIPOSIT,
      ACCOUNT_CODE_UNPAID,
      ACCOUNT_CODE_DEPOSITS_RECEIVED,
      ACCOUNT_CODE_SALE,
      ACCOUNT_CODE_COST_OF_SALES,
      ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE,
      ACCOUNT_CODE_NON_OPERATING_PROFIT,
      ACCOUNT_CODE_NON_OPERATING_EXPENSE,
      ACCOUNT_CODE_EXTRAORDINARY_PROFIT,
      ACCOUNT_CODE_EXTRAORDINARY_EXPENSE,
      ACCOUNT_CODE_ASSETS,
      ACCOUNT_CODE_DEBT,
      ACCOUNT_CODE_CAPITAL,
      ACCOUNT_CODE_REVENUE,
      ACCOUNT_CODE_EXPENSE,
      ACCOUNT_CODE_PROFIT,
    ].each{ |code|
      account = Account.find_by_code( code )
      account.system_required = true
      account.save!
    }
  end

  def self.down
    remove_column :accounts, "system_required"
  end
end
