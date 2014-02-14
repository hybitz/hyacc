# -*- encoding : utf-8 -*-
#
# $Id: 20100119110244_create_table_customer_names.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Util
  include HyaccDateUtil
end

class Customer < ActiveRecord::Base
  has_many :customer_names, :dependent=>:destroy
  accepts_nested_attributes_for :customer_names
end

class CreateTableCustomerNames < ActiveRecord::Migration
  
  def self.up
    create_table :customer_names do |t|
      t.integer :customer_id, :null=>false
      t.string :name, :null=>false
      t.string :formal_name, :null=>false
      t.date :start_date, :null=>false
      t.timestamps
    end
    
    add_index :customer_names, :customer_id, :unique=>false,
       :name=>:index_customer_names_on_customer_id

    # カラム情報を最新にする
    CustomerName.reset_column_information
    
    util = Util.new
    date = util.to_date(Company.find(:first).founded_date)
    
    Customer.find(:all).each do |c|
      p c.name + ' : ' + c.formal_name
      cn = CustomerName.new
      cn.customer_id = c.id
      cn.name = c.name
      cn.formal_name = c.formal_name.to_s.length > 0 ? c.formal_name : c.name
      cn.start_date = date
      cn.save!
    end
    
    remove_column :customers, :name
    remove_column :customers, :formal_name
  end

  def self.down
    add_column :customers, :name
    add_column :customers, :formal_name
    
    Customer.find(:all).each do |c|
      c.name = c.customer_names[0].name
      c.formal_name = c.customer_names[0].formal_name
    end
    
    drop_table :customer_names
  end
end
