# -*- encoding : utf-8 -*-
class CreateRents < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    create_table :rents do |t|
      t.integer :rent_type, :limit => 1, :null => false
      t.integer :usage_type, :limit => 1, :null => false
      t.string :address
      t.string :landlord_name
      t.string :landlord_address
      t.string :name
      t.integer :status, :limit => 1, :null => false

      t.timestamps
    end
    a = Account.find_by_code(ACCOUNT_CODE_RENT)
    a.sub_account_type = SUB_ACCOUNT_TYPE_RENT
    a.save!
  end

  def self.down
    Rent.delete_all
    a = Account.find_by_code(ACCOUNT_CODE_RENT)
    a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
    a.save!
    drop_table :rents
  end
end
