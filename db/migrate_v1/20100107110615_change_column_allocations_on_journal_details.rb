# -*- encoding : utf-8 -*-
#
# $Id: 20100107110615_change_column_allocations_on_journal_details.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class ChangeColumnAllocationsOnJournalDetails < ActiveRecord::Migration
  def self.up
    JournalDetail.update_all("is_allocated_cost=0", "is_allocated_cost is null")
    JournalDetail.update_all("is_allocated_assets=0", "is_allocated_assets is null")

    change_column :journal_details, :is_allocated_cost, :boolean, :null=>false, :default=>false
    change_column :journal_details, :is_allocated_assets, :boolean, :null=>false, :default=>false
  end

  def self.down
    change_column :journal_details, :is_allocated_cost, :integer, :limit=>1
    change_column :journal_details, :is_allocated_assets, :integer, :limit=>1
  end
end
