# -*- encoding : utf-8 -*-
#
# $Id: 20100302111125_create_table_input_frequencies.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateTableInputFrequencies < ActiveRecord::Migration
  def self.up
    create_table :input_frequencies, :force => true do |t|
      t.integer :user_id, :null=>false
      t.integer :input_type, :null=>false, :limit=>1
      t.string :input_value
      t.integer :frequency, :null=>false
      t.timestamps
    end
    
    add_index :input_frequencies, [:user_id, :input_type, :input_value], :unique=>true,
      :name=>'index_input_frequencies_for_unique_key'
  end

  def self.down
    drop_table :input_frequencies
  end
end
