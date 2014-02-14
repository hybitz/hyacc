# -*- encoding : utf-8 -*-
#
# $Id: 20100221051054_create_table_employees.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateTableEmployees < ActiveRecord::Migration
  def self.up
    create_table :employees, :force => true do |t|
      t.integer  "company_id",                           :null => false
      t.string   "first_name",                           :null => false
      t.string   "last_name",                            :null => false
      t.date     "employment_date",                      :null => false
      t.string   "zip_code"
      t.string   "address"
      t.string   "sex",                     :limit => 1, :null => false
      t.boolean  "deleted",           :default => false, :null => false
      t.timestamps
    end
    
    add_column :users, :employee_id, :integer
    
    # カラム情報を最新にする
    Employee.reset_column_information
    User.reset_column_information
    
    User.find(:all).each do |u|
      e = Employee.new
      e.company_id = u.company_id
      e.last_name = u.last_name
      e.first_name = u.first_name
      e.employment_date = u.employment_date
      e.sex = u.sex
      e.zip_code = u.zip_code
      e.address = u.address
      e.deleted = u.deleted
      e.created_at = u.created_on
      e.updated_at = u.updated_on
      e.users << u
      e.save!
    end
    
    remove_column :users, :last_name
    remove_column :users, :first_name
    remove_column :users, :employment_date
    remove_column :users, :sex
    remove_column :users, :zip_code
    remove_column :users, :address
  end

  def self.down
    add_column :users, :last_name, :string, :null=>false
    add_column :users, :first_name, :string, :null=>false
    add_column :users, :employment_date, :date, :null=>false
    add_column :users, :sex, :string, :limit=>1, :null=>false
    add_column :users, :zip_code, :string
    add_column :users, :address, :string
    
    # カラム情報を最新にする
    User.reset_column_information
    
    Employee.find(:all).each do |e|
      e.users.each do |u|
        u.last_name = e.last_name
        u.first_name = e.first_name
        u.employment_date = e.employment_date
        u.sex = e.sex
        u.zip_code = e.zip_code
        u.address = e.address
        u.save!
      end
    end

    remove_column :users, :employee_id
    drop_table :employees
  end
end
