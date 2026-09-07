require 'test_helper'

class ExemptionsTest < ActiveSupport::TestCase

  def test_fiscal_year_for_december_of_calendar_year_期首が7月以降
    company = Company.first
    assert company.start_month_of_fiscal_year >= 7
    exemptions = Exemption.where(company_id: company.id)
    assert_equal [2008, 2007],  [exemptions[0].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[0].yyyy]
    assert_equal [2009, 2008],  [exemptions[1].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[1].yyyy]
    assert_equal [2010, 2009],  [exemptions[2].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[2].yyyy]
  end

  def test_fiscal_year_for_december_of_calendar_year_期首が6月以前
    company = Company.second
    assert company.start_month_of_fiscal_year <= 6
    employee = Employee.find_by(company_id: company.id)
    [2007, 2008, 2009].each do |y|
      Exemption.create!(employee_id: employee.id, company_id: company.id, yyyy: y)
    end
    exemptions = Exemption.where(company_id: company.id)
    assert_equal [2007, 2007], [exemptions[0].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[0].yyyy]
    assert_equal [2008, 2008], [exemptions[1].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[1].yyyy]
    assert_equal [2009, 2009], [exemptions[2].fiscal_year_for_december_of_calendar_year.fiscal_year, exemptions[2].yyyy]
  end

  def test_life_insurance_premium_2026_新契約のみ_フラグなしは上限4万
    e = Exemption.new(yyyy: 2026, has_dependent_under_23: false, life_insurance_premium_new: 120_000)
    assert_equal 40_000, e.life_insurance_premium
  end

  def test_life_insurance_premium_2026_新契約のみ_フラグありは特例の上限6万
    e = Exemption.new(yyyy: 2026, has_dependent_under_23: true, life_insurance_premium_new: 30_000)
    assert_equal 30_000, e.life_insurance_premium

    e.life_insurance_premium_new = 60_000
    assert_equal 45_000, e.life_insurance_premium

    e.life_insurance_premium_new = 120_000
    assert_equal 60_000, e.life_insurance_premium

    e.life_insurance_premium_new = 120_001
    assert_equal 60_000, e.life_insurance_premium
  end

  def test_life_insurance_premium_2026_旧契約のみはフラグに関係なく上限5万
    e = Exemption.new(yyyy: 2026, has_dependent_under_23: true, life_insurance_premium_old: 100_001)
    assert_equal 50_000, e.life_insurance_premium

    e.has_dependent_under_23 = false
    assert_equal 50_000, e.life_insurance_premium
  end

  def test_life_insurance_premium_2026_新旧合算_フラグありは上限6万
    e = Exemption.new(
      yyyy: 2026,
      has_dependent_under_23: true,
      life_insurance_premium_old: 100_001,
      life_insurance_premium_new: 120_000
    )
    assert_equal 60_000, e.life_insurance_premium
  end

  def test_life_insurance_premium_2026_新旧合算_フラグなしは旧のみの上限5万
    e = Exemption.new(
      yyyy: 2026,
      has_dependent_under_23: false,
      life_insurance_premium_old: 100_001,
      life_insurance_premium_new: 120_000
    )
    assert_equal 50_000, e.life_insurance_premium
  end

  def test_life_insurance_premium_2026と2027年以外はフラグありでも新契約のみ上限4万
    e = Exemption.new(yyyy: 2025, has_dependent_under_23: true, life_insurance_premium_new: 120_000)
    assert_equal 40_000, e.life_insurance_premium

    e.yyyy = 2028
    assert_equal 40_000, e.life_insurance_premium
  end

  def test_life_insurance_deduction_2026_フラグあり_3区分合計12万超は12万
    e = Exemption.new(
      yyyy: 2026,
      has_dependent_under_23: true,
      life_insurance_premium_new: 120_000,
      care_insurance_premium: 80_001,
      private_pension_insurance_new: 80_001
    )
    assert_equal 120_000, e.life_insurance_deduction
  end

  def test_life_insurance_deduction_2025_3区分合計12万超は12万
    e = Exemption.new(
      yyyy: 2025,
      life_insurance_premium_old: 100_001,
      care_insurance_premium: 80_001,
      private_pension_insurance_old: 100_001
    )
    assert_equal 120_000, e.life_insurance_deduction
  end
end
