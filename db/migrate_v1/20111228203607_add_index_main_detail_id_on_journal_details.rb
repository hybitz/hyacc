# -*- encoding : utf-8 -*-
#
# $Id: 20111228203607_add_index_main_detail_id_on_journal_details.rb 2758 2011-12-28 20:55:59Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddIndexMainDetailIdOnJournalDetails < ActiveRecord::Migration
  def self.up
    add_index :journal_details, :main_detail_id, :name=>"index_journal_details_main_detail_id", :unique=>false
  end

  def self.down
    remove_index :journal_details, :name=>"index_journal_details_main_detail_id"
  end
end
