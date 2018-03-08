class ChangeColumnNameOnBranches < ActiveRecord::Migration[5.1]
  def up
    change_column_default :branches, :name, nil
  end
  
  def down
    change_column_default :branches, :name, ''
  end
end
