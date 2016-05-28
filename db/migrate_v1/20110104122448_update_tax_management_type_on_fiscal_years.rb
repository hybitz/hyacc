class UpdateTaxManagementTypeOnFiscalYears < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    FiscalYear.find(:all, :conditions=>['tax_management_type=?', TAX_MANAGEMENT_TYPE_DEEMED]).each do |fy|
      puts "update fiscal_year #{fy.fiscal_year}"
      fy.tax_management_type = TAX_MANAGEMENT_TYPE_EXCLUSIVE
      fy.save!
      
      JournalHeader.find(
          :all,
          :conditions=>['ym >= ? and ym <= ?',
            HyaccDateUtil.get_start_year_month_of_fiscal_year( fy.fiscal_year, fy.company.start_month_of_fiscal_year),
            HyaccDateUtil.get_end_year_month_of_fiscal_year( fy.fiscal_year, fy.company.start_month_of_fiscal_year )]).each do |jh|
        next if jh.tax_admin_info
        puts "update tax_admin_info for journal #{jh.id}"
        jh.save!
      end
    end
    
  end

  def self.down
  end
end
