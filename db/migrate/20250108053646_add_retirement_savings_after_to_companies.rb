class AddRetirementSavingsAfterToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :retirement_savings_after, :integer
  end
end