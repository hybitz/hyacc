class AddColumnLifeInsurancePremiumNewOnExemptions < ActiveRecord::Migration
  def change
    add_column :exemptions, :life_insurance_premium_new, :integer, :null => false, :default => 0
  end
end
