class ChangeColumnDeleteOnBanks < ActiveRecord::Migration
  def up
    change_column :banks, :deleted, :boolean, :null => false, :default => false
  end

  def down
    change_column :banks, :deleted, :boolean, :null => true, :default => false
  end
end
