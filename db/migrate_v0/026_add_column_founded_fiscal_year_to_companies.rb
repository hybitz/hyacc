# -*- encoding : utf-8 -*-
class AddColumnFoundedFiscalYearToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, "founded_fiscal_year", :integer, :limit => 4, :null => false
    
    # カラム情報を最新にする
    Company.reset_column_information
    
    # 創立年度の設定
    Company.find(:first).update_attributes( :founded_fiscal_year=> 2007 )
  end

  def self.down
    remove_column :companies, "founded_fiscal_year"
  end
end
