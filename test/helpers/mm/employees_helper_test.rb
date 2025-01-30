require 'test_helper'

class Mm::EmployeesHelperTest < ActionView::TestCase
  
  def test_render_duration
    assert_equal '1ヶ月', render_duration(0, 0)
    assert_equal '4ヶ月', render_duration(0, 4)
    assert_equal '2年7ヶ月', render_duration(2, 7)
  end
 
  def test_get_start_ym_of_retirement_savings
    employee = Employee.first
    employee.company.update!(retirement_savings_after: 3)

    employee.update!(employment_date: '20200101')
    assert_equal '2022年1月', get_start_ym_of_retirement_savings(employee)

    employee.update!(employment_date: '20200201')
    assert_equal '2022年2月', get_start_ym_of_retirement_savings(employee)

    employee.update!(employment_date: '20200701')
    assert_equal '2022年7月', get_start_ym_of_retirement_savings(employee)
  end

end
