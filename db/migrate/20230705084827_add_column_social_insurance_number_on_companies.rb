class AddColumnSocialInsuranceNumberOnCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :social_insurance_number, :string
  end
end
