# -*- encoding : utf-8 -*-
#
# $Id: 20101125121442_add_column_settlement_type_on_journal_details.rb 2342 2010-11-25 14:10:01Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnConsumptionEntryTypeOnFiscalYears < ActiveRecord::Migration
  def self.up
    add_column :fiscal_years, :consumption_entry_type, :integer, :limit=>1
  end

  def self.down
    remove_column :fiscal_years, :consumption_entry_type
  end
end
