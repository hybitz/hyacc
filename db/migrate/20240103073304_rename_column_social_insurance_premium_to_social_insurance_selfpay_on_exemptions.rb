class RenameColumnSocialInsurancePremiumToSocialInsuranceSelfpayOnExemptions < ActiveRecord::Migration[5.2]
  def change
    rename_column :exemptions, :social_insurance_premium, :social_insurance_selfpay
  end
end
