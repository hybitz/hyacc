# -*- encoding : utf-8 -*-
class RemoveLandlordNameAndLandlordAddressFromRents < ActiveRecord::Migration
  def self.up
    remove_column :rents, :landlord_name
    remove_column :rents, :landlord_address
  end

  def self.down
    add_column :rents, :landlord_address, :string
    add_column :rents, :landlord_name, :string
  end
end
