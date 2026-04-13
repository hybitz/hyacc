require 'test_helper'

class TaxUtilsTest < ActiveSupport::TestCase
  def test_get_health_insurance_202604_子ども子育て支援金は発生する
    insurance = TaxUtils.get_health_insurance(202604, '13', 300_000)
    assert_equal 690, insurance.child_and_childcare_support_all
    assert_equal 345, insurance.child_and_childcare_support_half
  end

  def test_get_health_insurance_202603_子ども子育て支援金は発生しない
    insurance = TaxUtils.get_health_insurance(202603, '13', 300_000)
    assert_equal 0, insurance.child_and_childcare_support_all
    assert_equal 0, insurance.child_and_childcare_support_half
  end
end
