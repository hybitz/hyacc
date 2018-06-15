class RemoveColumnBankIdForPayOnEmployees < ActiveRecord::Migration[5.2]
  def change
    remove_column :employees, :bank_id_for_pay, :integer
    remove_column :employees, :office_id_for_pay, :integer
  end
end
