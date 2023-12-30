class ChangeColumnEmployeeIdOnExemptions < ActiveRecord::Migration[5.2]
  def up
    change_column :exemptions, :employee_id, :integer, null: false
  end
  def down
    change_column :exemptions, :employee_id, :string, null: false
  end
end
