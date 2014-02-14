# -*- encoding : utf-8 -*-
#
# $Id: 20101125121442_add_column_settlement_type_on_journal_details.rb 2726 2011-12-09 06:15:15Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnSettlementTypeOnJournalDetails < ActiveRecord::Migration
  def self.up
    add_column :journal_details, :settlement_type, :integer, :limit=>1
  end

  def self.down
    remove_column :journal_details, :settlement_type
  end
end
