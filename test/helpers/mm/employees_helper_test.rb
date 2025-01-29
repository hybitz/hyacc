require 'test_helper'

class Mm::EmployeesHelperTest < ActionView::TestCase
  
  def test_render_duration
    assert_equal '1ヶ月', render_duration(0, 0)
    assert_equal '4ヶ月', render_duration(0, 4)
    assert_equal '2年7ヶ月', render_duration(2, 7)
  end
 
  def test_get_start_ym_of_retirement_savings
    employee = Employee.first
    company = employee.company
    assert_equal "2009年1月", employee.employment_date.strftime("%Y年%-m月")
    assert_nil company.retirement_savings_after
    assert_nil get_start_ym_of_retirement_savings(employee)

    company.update!(retirement_savings_after: 1)
    assert_equal "2009年1月", get_start_ym_of_retirement_savings(employee)

    company.update!(retirement_savings_after: 2)
    assert_equal "2010年1月", get_start_ym_of_retirement_savings(employee)

    company.update!(retirement_savings_after: 3)
    assert_equal "2011年1月", get_start_ym_of_retirement_savings(employee)
  end

end
