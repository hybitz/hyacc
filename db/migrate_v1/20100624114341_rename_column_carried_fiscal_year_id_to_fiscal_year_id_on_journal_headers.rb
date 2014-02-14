# -*- encoding : utf-8 -*-
#
# $Id: 20100624114341_rename_column_carried_fiscal_year_id_to_fiscal_year_id_on_journal_headers.rb 2724 2011-12-09 06:13:45Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class RenameColumnCarriedFiscalYearIdToFiscalYearIdOnJournalHeaders < ActiveRecord::Migration
  def self.up
    rename_column :journal_headers, :carried_fiscal_year_id, :fiscal_year_id
  end

  def self.down
    rename_column :journal_headers, :fiscal_year_id, :carried_fiscal_year_id
  end
end
