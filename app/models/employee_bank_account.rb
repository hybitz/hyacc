class EmployeeBankAccount < ApplicationRecord
  belongs_to :employee
  belongs_to :bank
  belongs_to :bank_office, optional: true
  

  def bank_name
    return nil unless bank
    bank.name
  end
  
  def bank_office_name
    return nil unless bank_office
    bank_office.name
  end
  
end
