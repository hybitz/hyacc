class AddColumnDisabledOnBanks < ActiveRecord::Migration
  def change
    add_column :banks, :disabled, :boolean, :null => false, :default => false
  end
end
