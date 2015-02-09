class AddColumnDisabledOnBankOffices < ActiveRecord::Migration
  def change
    add_column :bank_offices, :disabled, :boolean, :null => false, :default => false
  end
end
