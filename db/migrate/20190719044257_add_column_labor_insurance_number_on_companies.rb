class AddColumnLaborInsuranceNumberOnCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :labor_insurance_number, :string, limit: 14
  end
end
