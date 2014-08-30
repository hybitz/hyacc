module Employees
  include HyaccConstants

  def employee
    @_employee ||= Employee.first
  end
  
  def valid_employee_params(options = {})
    {
      :company_id => Company.first.id,
      :last_name => options[:last_name] || '山田',
      :first_name => '花子',
      :sex => SEX_TYPE_F,
      'employment_date(1i)' => '1990',
      'employment_date(2i)' => '1',
      'employment_date(3i)' => '1',
    }
  end
  
  def invalid_employee_params
    valid_employee_params(:last_name => '')
  end
end