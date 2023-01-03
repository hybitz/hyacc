class AddColumnSocialInsuranceReferenceNumberOnEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :social_insurance_reference_number, :integer
  end
end
