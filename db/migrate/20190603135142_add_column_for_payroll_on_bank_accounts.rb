class AddColumnForPayrollOnBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :for_payroll, :boolean, null: false, default: false
  end
end
