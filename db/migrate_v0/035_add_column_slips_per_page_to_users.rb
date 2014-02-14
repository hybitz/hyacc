# -*- encoding : utf-8 -*-
class AddColumnSlipsPerPageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, "slips_per_page", :integer, :limit=>3, :default=>20
  end

  def self.down
    remove_column :users, "slips_per_page"
  end
end
