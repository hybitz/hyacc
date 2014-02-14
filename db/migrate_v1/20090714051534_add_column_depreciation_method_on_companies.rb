# -*- encoding : utf-8 -*-
class AddColumnDepreciationMethodOnCompanies < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    add_column :companies, :depreciation_method, :integer, :null=>false, :limit=>1

    # カラム情報を最新にする
    Company.reset_column_information
    Company.update_all("depreciation_method=#{HyaccConstants::DEPRECIATION_METHOD_FIXED_RATE}")
  end

  def self.down
    remove_column :companies, :depreciation_method
  end
end
