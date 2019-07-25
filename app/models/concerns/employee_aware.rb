module EmployeeAware
  extend ActiveSupport::Concern
  include CompanyAware

  included do
    attr_accessor :employee_id
  end

  def employee
    if employee_id.present?
      @employee ||= company.employees.find(employee_id)
    end
  end

  def employees
    Employee.where(company_id: company_id, deleted: false)
  end
end