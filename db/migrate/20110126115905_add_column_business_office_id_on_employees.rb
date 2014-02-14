# -*- encoding : utf-8 -*-
#
# $Id: 20110126115905_add_column_business_office_id_on_employees.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnBusinessOfficeIdOnEmployees < ActiveRecord::Migration
  def self.up
    add_column :employees, :business_office_id, :integer
  end

  def self.down
    remove_column :employees, :business_office_id
  end
end
