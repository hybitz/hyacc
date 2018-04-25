class AddColumnEmploymentInsuranceOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :payrolls, :employment_insurance, :integer, null: false, default: 0
  end
end
