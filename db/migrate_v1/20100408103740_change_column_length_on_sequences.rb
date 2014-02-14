# -*- encoding : utf-8 -*-
#
# $Id: 20100408103740_change_column_length_on_sequences.rb 2115 2010-04-08 10:46:37Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class ChangeColumnLengthOnSequences < ActiveRecord::Migration
  def self.up
    change_column :sequences, :name, :string, :limit=>32, :null=>false
    change_column :sequences, :section, :string, :limit=>32
  end

  def self.down
    change_column :sequences, :name, :string, :null=>false
    change_column :sequences, :section, :string
  end
end
