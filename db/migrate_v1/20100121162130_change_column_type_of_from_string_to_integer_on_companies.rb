# -*- encoding : utf-8 -*-
#
# $Id: 20100121162130_change_column_type_of_from_string_to_integer_on_companies.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class ChangeColumnTypeOfFromStringToIntegerOnCompanies < ActiveRecord::Migration
  def self.up
    types = {}
    Company.find(:all).each do |c|
      types[c.id] = c.type_of
    end
    
    change_column :companies, :type_of, :integer, :limit=>1, :null=>false, :default=>0
    
    # カラム情報を最新にする
    Company.reset_column_information
    
    Company.find(:all).each do |c|
      c.type_of = types[c.id].to_i
      c.save!
    end
    
    change_column :companies, :type_of, :integer, :limit=>1, :null=>false
  end

  def self.down
    types = {}
    Company.find(:all).each do |c|
      types[c.id] = c.type_of
    end

    change_column :companies, :type_of, :string, :limit=>1, :null=>false, :default=>''
    
    # カラム情報を最新にする
    Company.reset_column_information
    
    Company.find(:all).each do |c|
      c.type_of = types[c.id].to_s
      c.save!
    end
    
    change_column :companies, :type_of, :string, :limit=>1, :null=>false
  end
end
