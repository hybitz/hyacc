class ChangeColumnParentIdOnBranches < ActiveRecord::Migration
  def up
    change_column :branches, :parent_id, :integer, :null => true, :default => nil
    Branch.where(:parent_id => 0).update_all(['parent_id = ?', nil])
  end
  
  def down
    change_column :branches, :parent_id, :integer, :null => false, :default => 0
  end
end
