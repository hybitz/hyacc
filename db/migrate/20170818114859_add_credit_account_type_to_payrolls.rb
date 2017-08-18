class AddCreditAccountTypeToPayrolls < ActiveRecord::Migration[5.0]
  def change
    add_column :payrolls, :credit_account_type_of_employee_insurance, :string, :null=>false, :limit => 1, :default=>'0'
  end
end
