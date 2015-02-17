# -*- encoding : utf-8 -*-
#
# $Id: 20130215072945_add_is_head_to_business_offices.rb 2993 2013-02-15 07:50:16Z hiro $
# Product: hyacc
# Copyright 2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
#ruby script/rails generate migration AddIsHeadToBusinessOffices isHead:boolean
class AddIsHeadToBusinessOffices < ActiveRecord::Migration
  def self.up
    add_column :business_offices, :isHead, :boolean, :default=>false, :null=>false
  end

  def self.down
    remove_column :business_offices, :isHead
  end
end
