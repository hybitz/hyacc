class EmployeeQualification < ApplicationRecord
  belongs_to :employee, inverse_of: 'employee_qualifications'
  belongs_to :qualification
end
