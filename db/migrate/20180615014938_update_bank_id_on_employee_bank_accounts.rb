class UpdateBankIdOnEmployeeBankAccounts < ActiveRecord::Migration[5.2]
  def up
    return unless Rails.env.production?

    i = EmployeeBankAccount.new
    i.employee_id = 1
    i.bank_id = 3
    i.bank_office_id = 3
    i.code = "1234657"
    i.save!
    
    h = EmployeeBankAccount.new
    h.employee_id = 2
    h.bank_id = 5
    h.bank_office_id = 5
    h.code = "1234657"
    h.save!
    
    k = EmployeeBankAccount.new
    k.employee_id = 3
    k.bank_id = 3
    k.bank_office_id = 3
    k.code = "1234657"
    k.save!
  end
  
  def down
    EmployeeBankAccount.delete_all
  end
end
