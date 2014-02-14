# -*- encoding : utf-8 -*-
#
# $Id: 20100304145230_create_table_branches_employees.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateTableBranchesEmployees < ActiveRecord::Migration
  def self.up
    create_table :branches_employees, :id => false, :force => true do |t|
      t.integer  "branch_id", :null=>false
      t.integer  "employee_id", :null=>false
      t.integer  "cost_ratio", :null=>false, :default => 0
      t.boolean  "default_branch", :null=>false, :default => false
      t.timestamps
    end
    
    # BranchesUserから移行
    BranchesEmployee.reset_column_information
    BranchesUser.find(:all).each do |bu|
      be = BranchesEmployee.new
      be.branch_id = bu.branch_id
      be.employee_id = bu.user.employee.id
      be.cost_ratio = bu.cost_ratio
      be.default_branch = bu.default_branch
      be.save!
    end
    
    drop_table :branches_users
  end

  def self.down
    create_table :branches_users, :id => false, :force => true do |t|
      t.integer  "branch_id", :null=>false
      t.integer  "user_id", :null=>false
      t.integer  "cost_ratio", :null=>false, :default => 0
      t.boolean  "default_branch", :null=>false, :default => false
      t.timestamps
    end

    # BranchesUserから復活
    BranchesUser.reset_column_information
    BranchesEmployee.find(:all).each do |be|
      bu = BranchesUser.new
      bu.branch_id = be.branch_id
      bu.user_id = be.employee.users.first.id
      bu.cost_ratio = be.cost_ratio
      bu.default_branch = be.default_branch
      bu.save!
    end

    drop_table :branches_employees
  end
end
