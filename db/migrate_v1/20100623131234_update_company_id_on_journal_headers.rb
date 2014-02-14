# -*- encoding : utf-8 -*-
#
# $Id: 20100623131234_update_company_id_on_journal_headers.rb 2724 2011-12-09 06:13:45Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class UpdateCompanyIdOnJournalHeaders < ActiveRecord::Migration
  def self.up
    c = Company.find(:first)
    JournalHeader.update_all(["company_id=?", c.id]) if c
    change_column :journal_headers, :company_id, :integer, :null=>false
  end

  def self.down
    change_column :journal_headers, :company_id, :integer
  end
end
