class ChangeColumnTypeOfOnCompanies < ActiveRecord::Migration
  def up
    change_column :companies, :type_of, :integer, :null => false
  end
  def down
    change_column :companies, :type_of, :boolean, :null => false
  end
end
