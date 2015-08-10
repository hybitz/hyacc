class RenameColumnUpdatedOnOnBranches < ActiveRecord::Migration
  def change
    rename_column :branches, :updated_on, :updated_at
  end
end
