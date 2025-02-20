require 'test_helper'

class Reports::SavingsModelTest < ActiveSupport::TestCase

  def test_total_amount
    finder = ReportFinder.new(user)
    finder.fiscal_year = company.founded_fiscal_year.fiscal_year
    finder.company_id = company.id
    logic = Reports::SavingsLogic.new(finder)

    @model = logic.build_model
    assert_equal [210], @model.details.map{|d| d.amount}.compact
    assert_equal 210, @model.total_amount
  end

end