class RemoveColumnParentIdOldOnAccounts < ActiveRecord::Migration
  def up
    remove_column :accounts, :parent_id_old
  end

  def down
    add_column :accounts, :parent_id_old, :integer
  end
end
