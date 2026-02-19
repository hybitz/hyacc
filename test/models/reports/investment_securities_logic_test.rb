require 'test_helper'

class Reports::InvestmentSecuritiesLogicTest < ActiveSupport::TestCase

  def test_build_model_購入は正で売却は負で集計される
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2016
    finder.company_id = company.id
    logic = Reports::InvestmentSecuritiesLogic.new(finder)
    model = logic.build_model

    detail = model.details.find { |d| d[:last_shares] == 300 && d[:last_trading_value] == 10_000 }
    assert detail
    assert_equal 300, detail[:last_shares]
    assert_equal 10_000, detail[:last_trading_value]
  end
end
