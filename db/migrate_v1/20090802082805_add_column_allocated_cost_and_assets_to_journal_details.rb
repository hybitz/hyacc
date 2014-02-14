# -*- encoding : utf-8 -*-
class AddColumnAllocatedCostAndAssetsToJournalDetails < ActiveRecord::Migration
  def self.up
    add_column :journal_details, :is_allocated_cost, :integer, :limit=>1
    add_column :journal_details, :is_allocated_assets, :integer, :limit=>1
  end

  def self.down
    remove_column :journal_details, :is_allocated_assets
    remove_column :journal_details, :is_allocated_cost
  end
end
