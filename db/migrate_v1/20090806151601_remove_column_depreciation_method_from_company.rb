# -*- encoding : utf-8 -*-
class RemoveColumnDepreciationMethodFromCompany < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    remove_column :companies, :depreciation_method
  end

  def self.down
    add_column :companies, :depreciation_method, :integer, :null=>false, :limit=>1

    # カラム情報を最新にする
    Company.reset_column_information
    Company.update_all("depreciation_method=#{DEPRECIATION_METHOD_FIXED_RATE}")
  end
end
