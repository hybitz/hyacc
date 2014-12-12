class AddColumnBirthOnEmployees < ActiveRecord::Migration
  def up
    add_column :employees, :birth, :date, :null => true
  end

  def down
    remove_column :employees, :birth
  end
end
