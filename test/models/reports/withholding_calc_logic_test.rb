require 'test_helper'

class Reports::WithholdingCalcLogicTest < ActiveSupport::TestCase

  def test_get_annual_tax
    finder = WithholdingSlipFinder.new
    finder.calendar_year = 2012
    finder.company_id = Company.first.id
    logic = Reports::WithholdingCalcLogic.new(finder)
    assert_equal 215300, logic.get_annual_tax
  end

end