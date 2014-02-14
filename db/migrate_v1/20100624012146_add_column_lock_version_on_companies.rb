# -*- encoding : utf-8 -*-
#
# $Id: 20100624012146_add_column_lock_version_on_companies.rb 2724 2011-12-09 06:13:45Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnLockVersionOnCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :lock_version, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :companies, :lock_version
  end
end
