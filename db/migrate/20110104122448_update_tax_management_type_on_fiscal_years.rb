# -*- encoding : utf-8 -*-
#
# $Id: 20101125121442_add_column_settlement_type_on_journal_details.rb 2342 2010-11-25 14:10:01Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
# みなし消費税を税抜経理方式に変更する
#
class Util
  include HyaccDateUtil
end

class UpdateTaxManagementTypeOnFiscalYears < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    util = Util.new
    
    FiscalYear.find(:all, :conditions=>['tax_management_type=?', TAX_MANAGEMENT_TYPE_DEEMED]).each do |fy|
      puts "update fiscal_year #{fy.fiscal_year}"
      fy.tax_management_type = TAX_MANAGEMENT_TYPE_EXCLUSIVE
      fy.save!
      
      JournalHeader.find(
          :all,
          :conditions=>['ym >= ? and ym <= ?',
            util.get_start_year_month_of_fiscal_year( fy.fiscal_year, fy.company.start_month_of_fiscal_year),
            util.get_end_year_month_of_fiscal_year( fy.fiscal_year, fy.company.start_month_of_fiscal_year )]).each do |jh|
        next if jh.tax_admin_info
        puts "update tax_admin_info for journal #{jh.id}"
        jh.save!
      end
    end
    
  end

  def self.down
  end
end
