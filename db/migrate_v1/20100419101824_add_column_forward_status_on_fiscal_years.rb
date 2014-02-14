# -*- encoding : utf-8 -*-
#
# $Id: 20100419101824_add_column_forward_status_on_fiscal_years.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnForwardStatusOnFiscalYears < ActiveRecord::Migration
  def self.up
    add_column :fiscal_years, :carry_status, :boolean, :null=>false, :default=>false
    add_column :fiscal_years, :carried_at, :datetime
    add_column :fiscal_years, :lock_version, :integer, :null=>false, :default=>0
  end

  def self.down
    remove_column :fiscal_years, :carry_status
    remove_column :fiscal_years, :carried_at
    remove_column :fiscal_years, :lock_version
  end
end
