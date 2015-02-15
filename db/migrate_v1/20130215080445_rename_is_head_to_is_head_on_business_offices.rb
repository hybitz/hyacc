# -*- encoding : utf-8 -*-
#
# $Id: 20130215080445_rename_is_head_to_is_head_on_business_offices.rb 2995 2013-02-15 08:22:39Z hiro $
# Product: hyacc
# Copyright 2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class RenameIsHeadToIsHeadOnBusinessOffices < ActiveRecord::Migration
  def self.up
    rename_column :business_offices, :isHead, :is_head
  end

  def self.down
    rename_column :business_offices, :is_head, :isHead
  end
end
