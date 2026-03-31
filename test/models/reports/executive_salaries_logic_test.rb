require 'test_helper'

class Reports::ExecutiveSalariesLogicTest < ActiveSupport::TestCase

  def test_build_model_sets_employee_fields_from_employee
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2016
    finder.company_id = company.id
    finder.branch_id = branch.id
    logic = Reports::ExecutiveSalariesLogic.new(finder)
    model = logic.build_model

    detail = model.details.find { |d| d.employee_name == executive.fullname }
    assert detail
    assert_equal executive.position, detail.position
    assert_equal executive.address_on(logic.end_ymd), detail.address
    assert_equal executive.full_time, detail.full_time
    assert_equal executive.duty_description, detail.duty_description
    assert_equal executive.relationship_to_representative, detail.relationship

    assert_equal 400_000, detail.retirement_allowance_amount
    assert_equal 400_000, model.total_executive_retirement_allowance_amount
  end
end
