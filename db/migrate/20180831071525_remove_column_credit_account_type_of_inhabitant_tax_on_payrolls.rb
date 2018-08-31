class RemoveColumnCreditAccountTypeOfInhabitantTaxOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    remove_column :payrolls, :credit_account_type_of_inhabitant_tax, :string, null: false, limit: 1
  end
end
