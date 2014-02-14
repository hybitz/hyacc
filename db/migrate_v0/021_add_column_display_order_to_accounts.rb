# -*- encoding : utf-8 -*-
class AddColumnDisplayOrderToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, "display_order", :integer
  end

  def self.down
    remove_column :accounts, "display_order"
  end
end
