class RenameColumnSpecialTaxForSpecifiedFamilyToSpecialDeductionForSpecifiedFamilyOnExemptions < ActiveRecord::Migration[6.1]
  def change
    rename_column :exemptions, :special_tax_for_specified_family, :special_deduction_for_specified_family
  end
end
