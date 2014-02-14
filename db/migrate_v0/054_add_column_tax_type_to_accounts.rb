# -*- encoding : utf-8 -*-
class AddColumnTaxTypeToAccounts < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    add_column :accounts, "tax_type", :integer, :limit=>1, :null=>false
    
    # カラム情報を最新にする
    Account.reset_column_information
    
    # デフォルトで全科目を非課税に設定する
    Account.update_all("tax_type=#{TAX_TYPE_NONTAXABLE}")
  end

  def self.down
    remove_column :accounts, "tax_type"
  end
end
