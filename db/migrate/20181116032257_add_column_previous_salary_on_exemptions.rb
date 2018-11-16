class AddColumnPreviousSalaryOnExemptions < ActiveRecord::Migration[5.2]
  def change
    add_column :exemptions, :previous_salary, :integer
    add_column :exemptions, :previous_withholding_tax, :integer
    add_column :exemptions, :previous_social_insurance, :integer
    add_column :exemptions, :remarks, :text
  end
end
