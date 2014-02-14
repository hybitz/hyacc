# -*- encoding : utf-8 -*-
class AddColumnIsOrderEntryToCustomers < ActiveRecord::Migration

  def self.up
    
    add_column :customers, "is_order_entry", :boolean, :null=>false, :default => false
    add_column :customers, "is_order_placement", :boolean, :null=>false, :default => false
    add_column :customers, "address", :string, :default => ""
    add_column :customers, "formal_name", :string, :default => ""

    # カラム情報を最新にする
    Customer.reset_column_information
    # デフォルトで全科目を受注フラグをONに設定する
    Customer.update_all("is_order_entry=true")
  end

  def self.down
    remove_column :customers, "is_order_entry"
    remove_column :customers, "is_order_placement"
    remove_column :customers, "address"
    remove_column :customers, "formal_name"
  end
end
