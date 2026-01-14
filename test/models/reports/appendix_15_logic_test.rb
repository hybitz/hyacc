require 'test_helper'

class Reports::Appendix15LogicTest < ActiveSupport::TestCase

  def test_get_business_months
    finder = ReportFinder.new(user)
    finder.fiscal_year = company.founded_fiscal_year.fiscal_year
    finder.company_id = company.id
    logic = Reports::Appendix15Logic.new(finder)

    @model = logic.build_model
    assert_equal 12, company.start_month_of_fiscal_year
    assert_equal 2, company.founded_date.month
    assert_equal 10, @model.get_business_months
  end

end