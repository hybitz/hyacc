class EmployeeBankAccount < ApplicationRecord
  belongs_to :employee
  belongs_to :bank
  belongs_to :bank_office, optional: true
  

  def bank_name
    bank.try(:name)
  end
  
  def bank_office_name
    bank_office.try(:name)
  end
  
end
