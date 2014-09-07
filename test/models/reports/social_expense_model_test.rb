require 'test_helper'

class Reports::SocialExpenseModelTest < ActiveSupport::TestCase

  def test_get_business_months
    @model = Reports::SocialExpenseModel.new
    @model.company = company
    @model.fiscal_year = company.founded_fiscal_year.fiscal_year
    
    assert_equal 12, company.start_month_of_fiscal_year
    assert_equal 2, company.founded_date.month
    assert_equal 10, @model.get_business_months
  end

end