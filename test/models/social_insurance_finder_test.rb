require 'test_helper'

class SocialInsuranceFinderTest < ActiveSupport::TestCase
  def setup
    @finder = SocialInsuranceFinder.new(company_id: 1, fiscal_year: 2026)

    employee1 = Employee.first
    employee2 = Employee.second
    employee3 = Employee.find(6)
    Payroll.create!(employee: employee1, ym: 202601, pay_day: "2026-02-25",
      base_salary: 300000, create_user_id: 1, update_user_id: 1)
    Payroll.create!(employee: employee2, ym: 202601, pay_day: "2026-02-25",
      base_salary: 300000, create_user_id: 1, update_user_id: 1)
    Payroll.create!(employee: employee3, ym: 202601, pay_day: "2026-02-25",
      base_salary: 300000, create_user_id: 1, update_user_id: 1)
  end

  def test_employees_are_sorted_by_social_insurance_reference_number
    result = @finder.list_payrolls_by_employee.map(&:first)
    reference_numbers = result.map(&:social_insurance_reference_number)
    expected_order = reference_numbers.compact.sort + [nil] * reference_numbers.count(&:nil?)
    assert_equal expected_order, reference_numbers
  end
end