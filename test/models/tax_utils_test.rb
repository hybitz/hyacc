require 'test_helper'

class TaxUtilsTest < ActiveSupport::TestCase
  def test_get_welfare_pension_202604_子ども子育て支援金は発生する
    insurance = TaxUtils.get_welfare_pension(202604, 300_000)
    assert_equal 690, insurance.child_and_childcare_support_all
    assert_equal 345, insurance.child_and_childcare_support_half
  end

  def test_get_welfare_pension_202603_子ども子育て支援金は発生しない
    insurance = TaxUtils.get_welfare_pension(202603, 300_000)
    assert_equal 0, insurance.child_and_childcare_support_all
    assert_equal 0, insurance.child_and_childcare_support_half
  end

  # 標準報酬月額が厚生年金の上限等級を超える場合でも、支援金は健康保険側の標準報酬月額（等級表）を基礎とする
  def test_get_social_insurance_202606_子ども子育て支援金は厚生年金の上限額で頭打ちしない
    insurance = TaxUtils.get_social_insurance(202606, '13', 700_000)
    assert_equal 1633.0, insurance.child_and_childcare_support_all
    assert_equal 816.5, insurance.child_and_childcare_support_half
  end
end
