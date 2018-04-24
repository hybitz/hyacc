class RemoveColumnCreditAccountTypeOfPensionOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    remove_column :payrolls, :credit_account_type_of_pension, :string, limit: 1, default: "0", null: false
  end
end
