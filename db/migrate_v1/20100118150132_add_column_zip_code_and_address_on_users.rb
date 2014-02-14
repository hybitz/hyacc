# -*- encoding : utf-8 -*-
class AddColumnZipCodeAndAddressOnUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :zip_code, :string
    add_column :users, :address, :string
  end

  def self.down
    remove_column :users, :zip_code
    remove_column :users, :address
  end
end
