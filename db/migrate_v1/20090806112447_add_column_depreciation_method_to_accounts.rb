# -*- encoding : utf-8 -*-
class AddColumnDepreciationMethodToAccounts < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    add_column :accounts, :depreciation_method, :integer, :limit=>1, :null=>true
    
    # カラム情報を最新にする
    Account.reset_column_information
    
    Account.update_all("depreciation_method=#{DEPRECIATION_METHOD_FIXED_RATE}",
      "path like '%#{ACCOUNT_CODE_FIXED_ASSET}%'")
  end

  def self.down
    remove_column :accounts, :depreciation_method
  end
end
