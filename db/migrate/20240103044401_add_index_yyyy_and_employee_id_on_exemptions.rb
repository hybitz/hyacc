class AddIndexYyyyAndEmployeeIdOnExemptions < ActiveRecord::Migration[5.2]
  def change
    add_index :exemptions, [:yyyy, :employee_id], unique: true
  end
end
