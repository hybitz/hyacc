# -*- encoding : utf-8 -*-
#
# $Id: 20100518012950_change_column_zip_code_on_rents.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class ChangeColumnZipCodeOnRents < ActiveRecord::Migration
  def self.up
    change_column :rents, :zip_code, :string, :limit=>7
  end

  def self.down
    change_column :rents, :zip_code, :integer, :limit=>7
  end
end
