class ChangeColumnDeletedOnBankOffices < ActiveRecord::Migration
  def up
    change_column :bank_offices, :deleted, :boolean, :null => false, :default => false
  end
  
  def down
    change_column :bank_offices, :deleted, :boolean, :null => true, :default => nil
  end
end
