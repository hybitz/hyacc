class AddColumnEmploymentInsuranceTypeOnCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :employment_insurance_type, :integer
  end
end
