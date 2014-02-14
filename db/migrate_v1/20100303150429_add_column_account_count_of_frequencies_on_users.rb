# -*- encoding : utf-8 -*-
#
# $Id: 20100303150429_add_column_account_count_of_frequencies_on_users.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnAccountCountOfFrequenciesOnUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :account_count_of_frequencies, :integer, :null=>false, :default=>10
  end

  def self.down
    remove_column :users, :account_count_of_frequencies
  end
end
