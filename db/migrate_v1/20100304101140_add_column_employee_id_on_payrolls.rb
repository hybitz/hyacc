# -*- encoding : utf-8 -*-
#
# $Id: 20100304101140_add_column_employee_id_on_payrolls.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnEmployeeIdOnPayrolls < ActiveRecord::Migration
  def self.up
    add_column :payrolls, :employee_id, :integer
    
    # ユーザIDから従業員IDを特定
    Payroll.reset_column_information
    Payroll.find(:all).each do |p|
      p.employee_id = User.find(p.user_id).employee_id
      p.save!
    end
    
    change_column :payrolls, :employee_id, :integer, :null=>false
    remove_column :payrolls, :user_id
  end

  def self.down
    add_column :payrolls, :user_id, :integer
    
    # 従業員IDからユーザIDを特定
    Payroll.reset_column_information
    Payroll.find(:all).each do |p|
      p.user_id = Employee.find(p.employee_id).users.first.id
      p.save!
    end
    
    change_column :payrolls, :user_id, :integer, :null=>false
    remove_column :payrolls, :employee_id
  end
end
