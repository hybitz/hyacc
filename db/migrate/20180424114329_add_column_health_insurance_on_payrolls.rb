class AddColumnHealthInsuranceOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :payrolls, :health_insurance, :integer, null: false, default: 0
  end
end
