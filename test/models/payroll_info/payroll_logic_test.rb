require 'test_helper'
require 'minitest/mock'

class PayrollInfo::PayrollLogicTest < ActiveSupport::TestCase
  
  def test_get_total_base_salary
    logic = logic_builder(2008)
    assert_equal 2_653_000, logic.get_total_base_salary
  end
  
  def test_get_base_salaries
    logic = logic_builder(2008)
    assert_equal 349_000, logic.get_base_salaries["20080625"]
  end
  
  def test_get_deduction
    logic = logic_builder(2008)
    assert_equal 975_600, logic.get_deduction

    logic = logic_builder(2025)
    logic.stub(:get_total_base_salary_include_previous, 1_899_999) do
      assert_equal 1_899_999, logic.get_total_deemed_salary
      assert_equal 650_000, logic.get_deduction
    end
    logic.stub(:get_total_base_salary_include_previous, 1_903_999) do
      assert_equal 1_900_000, logic.get_total_deemed_salary
      assert_equal 650_000, logic.get_deduction
    end
    logic.stub(:get_total_base_salary_include_previous, 1_904_000) do
      assert_equal 1_904_000, logic.get_total_deemed_salary
      assert_equal 651_200, logic.get_deduction
    end
  end

  def test_get_deduction_2026
    logic = logic_builder(2026)
    [
      [690_999, 690_999, 740_000],
      [691_000, 691_000, 691_000],
      [740_999, 740_999, 740_999],
      [741_000, 741_000, 740_000],
      [2_190_999, 2_190_999, 740_000],
      [2_191_000, 2_191_000, 2_191_000 - 1_451_000],
      [2_192_999, 2_192_999, 2_192_999 - 1_451_000],
      [2_193_000, 2_193_000, 2_193_000 - 1_453_000],
      [2_195_999, 2_195_999, 2_195_999 - 1_453_000],
      [2_196_000, 2_196_000, 2_196_000 - 1_456_000],
      [2_199_999, 2_199_999, 2_199_999 - 1_456_000],
      [2_200_000, 2_200_000, 740_000],
      [2_203_999, 2_200_000, 740_000],
      [2_204_000, 2_204_000, 741_200],
    ].each do |total_base_salary_include_previous, deemed_salary, deduction|
      logic.stub(:get_total_base_salary_include_previous, total_base_salary_include_previous) do
        assert_equal deemed_salary, logic.get_total_deemed_salary
        assert_equal deduction, logic.get_deduction
      end
    end
  end
    
  def test_get_after_deduction
    logic = logic_builder(2008)
    # みなし給与のため給与を4000で除して端数を削除後に4000を掛ける
    assert_equal 2_652_000 - 975_600, logic.get_after_deduction

    logic = logic_builder(2025)
    logic.stub(:get_total_base_salary_include_previous, 10_000_000) do
      assert_equal 150_000, logic.get_income_adjustment_deduction
      assert_equal 1_950_000, logic.get_deduction
      assert_equal 10_000_000 - 1_950_000 - 150_000, logic.get_after_deduction
    end
  end

  def test_get_total_exemption
    logic = logic_builder(2008)
    # 3565000（基本給）
    assert_equal 1_062_455, logic.get_total_exemption
  end

  def test_total_exemption_should_include_special_deduction_for_specified_family
    logic = logic_builder(2025)
    assert_equal 630_000, logic.get_exemptions.special_deduction_for_specified_family
    assert_equal 630_000, logic.get_total_exemption - logic.get_exemptions.basic
  end

  def test_get_withholding_tax
    logic = logic_builder(2008)
    # (2652000 - 975600 - 1062455)/1000 * 1000 * 0.05 /100 *100
    assert_equal 30_600, logic.get_withholding_tax
  end
    
  def test_get_health_insurance
    logic = logic_builder(2012)
    assert_equal 230_184, logic.get_health_insurance
  end
  
  def test_get_employee_pention
    logic = logic_builder(2012)
    assert_equal 381_033, logic.get_employee_pention
  end
  
  def test_get_withholding_taxes_salary
    logic = logic_builder(2012)
    withholding_taxes = logic.get_withholding_taxes_salary
    assert_equal 18_610, withholding_taxes["20120106"]
  end
  
  def test_get_withholding_taxes_of_bonus
    logic = logic_builder(2012)
    withholding_taxes = logic.get_withholding_taxes_of_bonus
    assert_equal 55675, withholding_taxes["20120120"]
  end
  
  def test_get_withholding_taxes
    logic = logic_builder(2012)
    withholding_taxes = logic.get_withholding_taxes(false)
    assert_equal 18610, withholding_taxes["20120106"]
  end

  def test_get_income_adjustment_deduction
    logic = logic_builder(2025)
    e = logic.get_exemptions
    assert e.income_adjustment_deduction_reason.present?

    logic.stub(:get_total_base_salary_include_previous, 8_500_000) do
      assert_equal 0, logic.get_income_adjustment_deduction
    end
    logic.stub(:get_total_base_salary_include_previous, 8_500_001) do
      assert_equal 1, logic.get_income_adjustment_deduction
    end
    logic.stub(:get_total_base_salary_include_previous, 9_999_991) do
      assert_equal 150_000, logic.get_income_adjustment_deduction
    end
    logic.stub(:get_total_base_salary_include_previous, 10_000_000) do
      assert_equal 150_000, logic.get_income_adjustment_deduction
    end
    logic.stub(:get_total_base_salary_include_previous, 15_000_000) do
      assert_equal 150_000, logic.get_income_adjustment_deduction
    end

    e.update!(income_adjustment_deduction_reason: nil)
    logic.stub(:get_total_base_salary_include_previous, 15_000_000) do
      assert_equal 0, logic.get_income_adjustment_deduction
    end
  end

  private

  def logic_builder(calendar_year)
    PayrollInfo::PayrollLogic.new(calendar_year, user.employee.id)
  end
  
end
