require 'test_helper'

class Mm::EmployeesHelperTest < ActionView::TestCase
  
  def test_render_duration
    assert_equal '1ヶ月', render_duration(0, 0)
    assert_equal '4ヶ月', render_duration(0, 4)
    assert_equal '2年7ヶ月', render_duration(2, 7)
  end
 
  def test_get_start_ym_of_retirement_savings
    assert_equal 3, company.retirement_savings_after
    employees = Employee.where(company_id: company.id)
    employees[0].update!(employment_date: '20200101')
    employees[1].update!(employment_date: '20210201')
    employees[2].update!(employment_date: '20220701')
    assert_equal ['2022年1月', '2023年2月', '2024年7月'], [get_start_ym_of_retirement_savings(employees[0]), get_start_ym_of_retirement_savings(employees[1]), get_start_ym_of_retirement_savings(employees[2])]
      
    company.update!(retirement_savings_after: 1)
    employees = Employee.where(company_id: company.id)
    assert_equal ['2020年1月', '2021年2月', '2022年7月'], [get_start_ym_of_retirement_savings(employees[0]), get_start_ym_of_retirement_savings(employees[1]), get_start_ym_of_retirement_savings(employees[2])]

    company.update!(retirement_savings_after: 2)
    employees = Employee.where(company_id: company.id)
    assert_equal ['2021年1月', '2022年2月', '2023年7月'],  [get_start_ym_of_retirement_savings(employees[0]), get_start_ym_of_retirement_savings(employees[1]), get_start_ym_of_retirement_savings(employees[2])]    
  end

end