# -*- encoding : utf-8 -*-
#
# $Id: 20101022124416_remove_column_system_required_from_accounts.rb 2725 2011-12-09 06:14:40Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class RemoveColumnSystemRequiredFromAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :system_required
  end

  def self.down
    add_column :accounts, :system_required, :boolean, :default=>false, :null=>false
  end
end
