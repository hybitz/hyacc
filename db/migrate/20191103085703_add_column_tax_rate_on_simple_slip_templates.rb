class AddColumnTaxRateOnSimpleSlipTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :simple_slip_templates, :tax_rate, :decimal, precision: 4, scale: 3
  end
end
