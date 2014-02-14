# -*- encoding : utf-8 -*-
#
# $Id: 20090821153805_add_index_ym_on_journal_headers.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddIndexYmOnJournalHeaders < ActiveRecord::Migration
  def self.up
    add_index :journal_headers, :ym, :unique=>false
  end

  def self.down
    remove_index :journal_headers, :ym
  end
end
