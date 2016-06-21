class ChangeColumnBirthOnEmployees < ActiveRecord::Migration
  def up
    change_column :employees, :birth, :date, :null => false
  end

  def down
    change_column :employees, :birth, :date, :null => true
  end
end
