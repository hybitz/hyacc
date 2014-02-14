class DropTableTaxRates < ActiveRecord::Migration
  def up
    drop_table :tax_rates
  end

  def down
  end
end
