class AddColumnSpecialTaxForSpecifiedFamilyOnExemptions < ActiveRecord::Migration[6.1]
  def change
    add_column :exemptions, :special_tax_for_specified_family, :integer
  end
end
