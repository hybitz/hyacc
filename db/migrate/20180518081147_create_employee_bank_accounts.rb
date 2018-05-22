class CreateEmployeeBankAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_bank_accounts do |t|
      t.integer  :employee_id,    null: false
      t.string   :code,           null: false
      t.integer  :bank_id,        null: false
      t.integer  :bank_office_id, null: false
      t.timestamps
    end
  end
end
