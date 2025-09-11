require 'test_helper'

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

    p = Payroll.new(ym: 202501, pay_day: '2025-02-25', employee: employee, base_salary: 1_903_999)
    p.create_user_id = p.update_user_id = employee.id
    p.save!

    logic = logic_builder(2025)
    assert logic.get_total_deemed_salary <= 1_900_000
    assert_equal 650_000, logic.get_deduction

    p.update!(base_salary: 1_904_000)
    logic = logic_builder(2025)
    assert logic.get_total_deemed_salary >= 1_900_001
    deduction = logic.get_total_deemed_salary*0.3 + 80_000
    assert_equal deduction, logic.get_deduction
  end
    
  def test_get_after_deduction
    logic = logic_builder(2008)
    # みなし給与のため給与を4000で除して端数を削除後に4000を掛ける
    assert_equal 2_652_000 - 975_600, logic.get_after_deduction
  end
    
  def test_get_total_exemption
    logic = logic_builder(2008)
    # 3565000（基本給）
    assert_equal 1_062_455, logic.get_total_exemption
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

  private

  def logic_builder(calendar_year)
    PayrollInfo::PayrollLogic.new(calendar_year, user.employee.id)
  end
  
end
