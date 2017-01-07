class RenameColumnLifeInsurancePremiumToLifeInsurancePremiumOldOnExemptions < ActiveRecord::Migration
  def change
    rename_column :exemptions, :life_insurance_premium, :life_insurance_premium_old
  end
end
