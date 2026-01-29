require 'test_helper'

class Reports::Appendix1402LogicTest < ActiveSupport::TestCase

  def test_build_model
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2026
    finder.company_id = company.id

    logic = Reports::Appendix1402Logic.new(finder)
    model = logic.build_model(100000000)

    assert_equal 1000, model.donations_designated_amount
    assert_equal 500, model.donations_public_interest_amount
    assert_equal 5000, model.donations_non_certified_trust_amount
    assert_equal 3000, model.donations_fully_controlled_amount
    assert_equal 4000, model.donations_foreign_affiliate_amount
    assert_equal 2000, model.donations_others_amount

    assert_equal 3, model.donations_designated_details.size
    assert_equal Date.new(2026, 1, 10), model.donations_designated_details[0].ymd
    assert_equal 1000, model.donations_designated_details[0].amount
    assert_nil model.donations_designated_details[1].ymd
    assert_nil model.donations_designated_details[2].ymd

    assert_equal 3, model.donations_public_interest_details.size
    assert_equal Date.new(2026, 2, 5), model.donations_public_interest_details[0].ymd
    assert_equal 500, model.donations_public_interest_details[0].amount

    assert_equal 3, model.donations_non_certified_trust_details.size
    assert_equal Date.new(2026, 1, 30), model.donations_non_certified_trust_details[0].ymd
    assert_equal 5000, model.donations_non_certified_trust_details[0].amount
    assert_nil model.donations_non_certified_trust_details[1].ymd
    assert_nil model.donations_non_certified_trust_details[2].ymd
  end

  def test_provisional_income_amount_is_set_from_parameter
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2026
    finder.company_id = company.id

    logic = Reports::Appendix1402Logic.new(finder)
    provisional_amount = 12345678
    model = logic.build_model(provisional_amount)

    assert_equal provisional_amount, model.provisional_income_amount
  end

  def test_appendix04_passes_correct_provisional_amount_to_appendix1402
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2026
    finder.company_id = company.id

    appendix04_logic = Reports::Appendix04Logic.new(finder)
    appendix04_model = appendix04_logic.build_model

    assert_equal appendix04_model.provisional_amount, appendix04_model.appendix_14_02_model.provisional_income_amount
  end
end

