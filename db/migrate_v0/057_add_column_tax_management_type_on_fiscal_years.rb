# -*- encoding : utf-8 -*-
class AddColumnTaxManagementTypeOnFiscalYears < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    add_column :fiscal_years, "tax_management_type", :integer, :limit=>1, :null=>false, :default=>TAX_MANAGEMENT_TYPE_EXEMPT
    
    # カラム情報を最新にする
    FiscalYear.reset_column_information
    
    # ハイビッツは2009年度より税抜経理方式に設定
    FiscalYear.find(:all, :conditions=>['company_id=?', 1]).each do |fy|
      if fy.fiscal_year < 2009
        fy.update_attributes( :tax_management_type=> TAX_MANAGEMENT_TYPE_EXEMPT )
      else
        fy.update_attributes( :tax_management_type=> TAX_MANAGEMENT_TYPE_EXCLUSIVE )
      end
    end
  end

  def self.down
    remove_column :fiscal_years, "tax_management_type"
  end
end
