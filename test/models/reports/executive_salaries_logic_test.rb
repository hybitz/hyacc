require 'test_helper'

class Reports::ExecutiveSalariesLogicTest < ActiveSupport::TestCase

  def test_build_model_sets_position_and_address_from_employee
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2016
    finder.company_id = company.id
    logic = Reports::ExecutiveSalariesLogic.new(finder)
    model = logic.build_model

    detail = model.details.find { |d| d.employee_name == executive.fullname }
    assert detail
    assert_equal executive.position, detail.position
    assert_equal executive.address_on(logic.end_ymd), detail.address
  end
end
