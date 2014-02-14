# -*- encoding : utf-8 -*-
#
# $Id: 20100623114856_add_column_company_id_on_journal_headers.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnCompanyIdOnJournalHeaders < ActiveRecord::Migration
  def self.up
    add_column :journal_headers, :company_id, :integer
  end

  def self.down
    remove_column :journal_headers, :company_id
  end
end
