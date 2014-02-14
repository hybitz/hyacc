class AddColumnTaxRateOnJournalDetails < ActiveRecord::Migration
  def up
    add_column :journal_details, :tax_rate, :decimal, :precision => 4, :scale => 3, :null => false, :default => 0.00
  end

  def down
    remove_column :journal_details, :tax_rate
  end
end
