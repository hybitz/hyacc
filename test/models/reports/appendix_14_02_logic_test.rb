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
    assert_equal donation_recipients(:one).id, model.donations_designated_details[0].donation_recipient.id
    assert_details_fill_count_and_others_nil model.donations_designated_details, 1

    assert_equal 3, model.donations_public_interest_details.size
    assert_equal Date.new(2026, 2, 5), model.donations_public_interest_details[0].ymd
    assert_equal 500, model.donations_public_interest_details[0].amount
    assert_details_fill_count_and_others_nil model.donations_public_interest_details, 1

    assert_equal 3, model.donations_non_certified_trust_details.size
    assert_equal Date.new(2026, 1, 30), model.donations_non_certified_trust_details[0].ymd
    assert_equal 5000, model.donations_non_certified_trust_details[0].amount
    assert_details_fill_count_and_others_nil model.donations_non_certified_trust_details, 2
  end

  private

  def assert_details_fill_count_and_others_nil(details, expected_fill_count = nil)
    present_indices = details.each_index.select { |i| details[i].ymd.present? }
    assert_equal expected_fill_count, present_indices.size

    details.each_with_index do |detail, idx|
      if present_indices.exclude?(idx)
        assert_nil detail.ymd
      end
    end
  end

  def test_appendix1402_gets_provisional_amount_from_appendix04
    finder = ReportFinder.new(user)
    finder.fiscal_year = 2026
    finder.company_id = company.id

    appendix04_core = Reports::Appendix04Logic.new(finder).build_core_model
    appendix1402_model = Reports::Appendix1402Logic.new(finder).build_model

    assert_equal appendix04_core.provisional_amount, appendix1402_model.provisional_income_amount
  end
end

