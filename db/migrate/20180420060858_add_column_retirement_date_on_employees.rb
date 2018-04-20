class AddColumnRetirementDateOnEmployees < ActiveRecord::Migration[5.1]
  def change
    add_column :employees, :retirement_date, :date
  end
end
