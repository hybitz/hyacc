class CreateTaxRates < ActiveRecord::Migration
  def change
    create_table :tax_rates do |t|
      t.date :start_date, :null => false
      t.decimal :rate, :precision => 4, :scale => 3, :null => false
      t.boolean :deleted, :null => false, :default => false
      t.timestamps
    end
  end
end
