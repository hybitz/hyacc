# -*- encoding : utf-8 -*-
#
# $Id: 20101129123552_updaet_is_tax_account_on_accounts.rb 2376 2010-11-29 12:43:35Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateTableEmployeeHistories < ActiveRecord::Migration
  def self.up
    create_table :employee_histories, :force => true do |t|
      t.integer :employee_id, :null=>false
      t.integer :num_of_dependent, :null=>false, :default=>0
      t.date :start_date,  :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_histories
  end
end
