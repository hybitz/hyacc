# -*- encoding : utf-8 -*-
#
# $Id: 20100618081449_add_column_business_type_id_on_companies.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnBusinessTypeIdOnCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :business_type_id, :integer
  end

  def self.down
    remove_column :companies, :business_type_id
  end
end
