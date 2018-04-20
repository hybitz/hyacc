module Employees
  include HyaccConstants

  def employee
    @_employee ||= Employee.first
  end
  
  def employee_params(options = {})
    {
      :last_name => options[:last_name] || '山田',
      :first_name => '花子',
      :sex => SEX_TYPE_F,
      :birth => 30.years.ago,
      :employment_date => '1990-01-01',
      :retirement_date => '9999-12-31',
      :my_number => '123456789012',
      :executive => false,
      :zip_code => '0600042',
      :zip_code_effective_at => Date.today - 3.years,
      :address => '北海道札幌市',
      :address_effective_at => Date.today - 3.years,
      :position => '代表取締役'
    }
  end
  
  def invalid_employee_params
    employee_params.merge(:last_name => '')
  end
end