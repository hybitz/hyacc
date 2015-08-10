class RenameColumnCreatedOnOnBranches < ActiveRecord::Migration
  def change
    rename_column :branches, :created_on, :created_at
  end
end
