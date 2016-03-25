class AddColumnAddressOnBankOffices < ActiveRecord::Migration
  def change
    add_column :bank_offices, :address, :string
  end
end
