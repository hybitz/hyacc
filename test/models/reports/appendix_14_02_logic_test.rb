require 'test_helper'

class Reports::Appendix1402LogicTest < ActiveSupport::TestCase

  def test_build_model
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2026
    finder.company_id = company.id

    logic = Reports::Appendix1402Logic.new(finder)
    model = logic.build_model

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
end

