# -*- encoding : utf-8 -*-
class AddColumnJournalDetailIdToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :journal_detail_id, :integer
  end

  def self.down
    remove_column :assets, :journal_detail_id
  end
end
