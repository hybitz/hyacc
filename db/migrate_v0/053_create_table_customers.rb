# -*- encoding : utf-8 -*-
class CreateTableCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :code, :default => "",    :null => false
      t.string :name, :default => "",    :null => false
      t.boolean  :deleted, :default => false, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
