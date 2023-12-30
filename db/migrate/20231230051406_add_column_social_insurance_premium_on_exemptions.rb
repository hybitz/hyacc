class AddColumnSocialInsurancePremiumOnExemptions < ActiveRecord::Migration[5.2]
  def change
    add_column :exemptions, :social_insurance_premium, :integer, after: :earthquake_insurance_premium
  end
end
