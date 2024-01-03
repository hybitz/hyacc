require 'test_helper'

class Reports::WithholdingTax::CalcLogicTest < ActiveSupport::TestCase

  def test_get_annual_tax
    finder = WithholdingSlipFinder.new
    finder.calendar_year = "2012"
    finder.company_id = Company.first.id
    logic = Reports::WithholdingTax::CalcLogic.new(finder)
    assert_equal 216500, logic.get_annual_tax
  end

end