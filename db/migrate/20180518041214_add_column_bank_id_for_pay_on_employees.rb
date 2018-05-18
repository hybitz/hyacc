class AddColumnBankIdForPayOnEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :bank_id_for_pay, :integer
    add_column :employees, :office_id_for_pay, :integer
  end
end
