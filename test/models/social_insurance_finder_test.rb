require 'test_helper'

class SocialInsuranceFinderTest < ActiveSupport::TestCase
  def setup
    @finder = SocialInsuranceFinder.new(company_id: 1, fiscal_year: 2026)

    [1, 2, 6].each do |employee_id|
      Payroll.create!(
        employee_id: employee_id,
        ym: 202601,
        pay_day: "2026-02-25",
        base_salary: 300000,
        create_user_id: 1,
        update_user_id: 1
      )
    end
  end

  def test_employees_are_sorted_by_social_insurance_reference_number
    result = @finder.list_payrolls_by_employee.map(&:first)
    expected_employee_ids = [6, 1, 2]
    expected_reference_numbers = [1, 10, nil]
    
    assert_equal expected_employee_ids, result.map(&:id)
    assert_equal expected_reference_numbers, result.map(&:social_insurance_reference_number)
  end
end