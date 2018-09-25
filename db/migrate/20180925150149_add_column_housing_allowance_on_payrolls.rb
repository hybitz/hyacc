class AddColumnHousingAllowanceOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :housing_allowance, :integer, null: false, default: 0
  end
end
