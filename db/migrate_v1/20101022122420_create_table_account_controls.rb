# -*- encoding : utf-8 -*-
#
# $Id: 20101022122420_create_table_account_controls.rb 2725 2011-12-09 06:14:40Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateTableAccountControls < ActiveRecord::Migration
  def self.up
    create_table :account_controls, :force => true do |t|
      t.integer :account_id, :null=>false
      t.boolean  :system_required, :default=>false, :null=>false
      t.boolean  :sub_account_editable, :default=>true, :null=>false
      t.timestamps
    end
    
    add_index :account_controls, [:account_id], :unique=>true, :name=>'index_account_controls_on_account_id'
  end

  def self.down
    drop_table :account_controls
  end
end
