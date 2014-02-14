# -*- encoding : utf-8 -*-
class AddColumnTaxJournalDetailOnJournalDetails < ActiveRecord::Migration
  def self.up
    add_column :journal_details, "detail_type", :integer, :limit=>1, :null=>false, :default=>1
    add_column :journal_details, "tax_type", :integer, :limit=>1, :null=>false, :default=>1
    add_column :journal_details, "main_detail_id", :integer
  end

  def self.down
    remove_column :journal_details, "detail_type"
    remove_column :journal_details, "tax_type"
    remove_column :journal_details, "main_detail_id"
  end
end
