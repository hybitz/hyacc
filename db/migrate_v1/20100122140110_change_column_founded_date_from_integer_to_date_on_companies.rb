class ChangeColumnFoundedDateFromIntegerToDateOnCompanies < ActiveRecord::Migration
  
  def self.up
    types = {}
    Company.find(:all).each do |c|
      types[c.id] = c.founded_date
    end
    
    change_column :companies, :founded_date, :date, :null=>true
    
    # カラム情報を最新にする
    Company.reset_column_information
    
    Company.find(:all).each do |c|
      c.founded_date = HyaccDateUtil.to_date(types[c.id])
      c.save!
    end
    
    change_column :companies, :founded_date, :date, :null=>false
  end

  def self.down
    types = {}
    Company.find(:all).each do |c|
      types[c.id] = c.founded_date
    end
    
    change_column :companies, :founded_date, :date, :null=>true

    # カラム情報を最新にする
    Company.reset_column_information
    
    Company.update_all("founded_date=null")

    change_column :companies, :founded_date, :integer, :null=>true
    
    # カラム情報を最新にする
    Company.reset_column_information
    
    Company.find(:all).each do |c|
      c.founded_date = HyaccDateUtil.to_int(types[c.id])
      c.save!
    end
    
    change_column :companies, :founded_date, :integer, :limit=>8, :null=>false
  end
end
