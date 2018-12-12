class AddColumnCareInsuranceNewOnExemptions < ActiveRecord::Migration[5.2]
  def change
    add_column :exemptions, :care_insurance_premium, :integer
    add_column :exemptions, :private_pension_insurance_new, :integer
    add_column :exemptions, :private_pension_insurance_old, :integer
  end
end
