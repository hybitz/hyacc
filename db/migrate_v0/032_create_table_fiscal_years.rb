# -*- encoding : utf-8 -*-
class CreateTableFiscalYears < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    create_table :fiscal_years do |t|
      t.column "company_id", :integer, :null=>false
      t.column "fiscal_year",                :integer,  :limit => 4,                    :null => false
      t.column "closing_status", :integer, :limit=>1, :default=>0, :null=>false
      t.column "deleted",                    :boolean,               :default => false, :null => false
      t.column "created_on",                 :datetime
      t.column "updated_on",                 :datetime
    end
    
    fy = FiscalYear.new
    fy.company_id = 1
    fy.fiscal_year = 2007
    fy.closing_status = CLOSING_STATUS_CLOSED
    fy.save!
    
    fy = FiscalYear.new
    fy.company_id = 1
    fy.fiscal_year = 2008
    fy.closing_status = CLOSING_STATUS_OPEN
    fy.save!
  end

  def self.down
    drop_table :fiscal_years
  end
end
