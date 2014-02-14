# -*- encoding : utf-8 -*-
#
# $Id: 20100122140110_change_column_founded_date_from_integer_to_date_on_companies.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Util
  include HyaccDateUtil
end

class ChangeColumnFoundedDateFromIntegerToDateOnCompanies < ActiveRecord::Migration
  
  def self.up
    util = Util.new
    
    types = {}
    Company.find(:all).each do |c|
      types[c.id] = c.founded_date
    end
    
    change_column :companies, :founded_date, :date, :null=>true
    
    # カラム情報を最新にする
    Company.reset_column_information
    
    Company.find(:all).each do |c|
      c.founded_date = util.to_date(types[c.id])
      c.save!
    end
    
    change_column :companies, :founded_date, :date, :null=>false
  end

  def self.down
    util = Util.new

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
      c.founded_date = util.to_int(types[c.id])
      c.save!
    end
    
    change_column :companies, :founded_date, :integer, :limit=>8, :null=>false
  end
end
