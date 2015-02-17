# -*- encoding : utf-8 -*-
#
# $Id: 20130215063926_add_tel_to_business_offices.rb 2990 2013-02-15 06:59:12Z hiro $
# Product: hyacc
# Copyright 2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
#ruby script/rails generate migration AddTelToBusinessOffices tel:string
class AddTelToBusinessOffices < ActiveRecord::Migration
  def self.up
    add_column :business_offices, :tel, :string, :limit=>13
  end

  def self.down
    remove_column :business_offices, :tel
  end
end
