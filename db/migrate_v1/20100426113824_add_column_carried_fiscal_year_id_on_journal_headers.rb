# -*- encoding : utf-8 -*-
#
# $Id: 20100426113824_add_column_carried_fiscal_year_id_on_journal_headers.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnCarriedFiscalYearIdOnJournalHeaders < ActiveRecord::Migration
  def self.up
    add_column :journal_headers, :carried_fiscal_year_id, :integer
  end

  def self.down
    remove_column :journal_headers, :carried_fiscal_year_id
  end
end
