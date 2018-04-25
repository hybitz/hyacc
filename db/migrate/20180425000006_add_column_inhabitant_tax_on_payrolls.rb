class AddColumnInhabitantTaxOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :payrolls, :inhabitant_tax, :integer, null: false, default: 0
  end
end
