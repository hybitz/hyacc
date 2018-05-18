class UpdateBankIdForPayOnEmployees < ActiveRecord::Migration[5.2]
  def change
    e = Employee.find(2)
    e.bank_id_for_pay = 4
    e.office_id_for_pay = 1
    e.save!
  end
end
