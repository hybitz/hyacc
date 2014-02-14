# -*- encoding : utf-8 -*-
class ChangeColumnsToCompanies < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    add_column :companies, "founded_date", :integer, :limit=>8, :null=>false
    remove_column :companies, "founded_fiscal_year"
    
    # 会社設立日を更新
    Company.reset_column_information
    Company.update_all( { :founded_date=>20070228 } )
    
  end

  def self.down
    remove_column :companies, "founded_date"
    add_column :companies, "founded_fiscal_year", :integer, :limit=>4, :null=>false
  end
end
