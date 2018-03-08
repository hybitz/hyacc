class AddColumnFormalNameOnBranches < ActiveRecord::Migration[5.1]
  def change
    add_column :branches, :formal_name, :string, null: false
  end
end
