require 'test_helper'

class PayrollHelperTest < ActionView::TestCase
  
  def test_get_pay_day
    assert_equal '20150123', get_pay_day("201501",1).strftime("%Y%m%d") # payday:0,25
    assert_equal '20150225', get_pay_day("201502",1).strftime("%Y%m%d")
    assert_equal '20150424', get_pay_day("201504",1).strftime("%Y%m%d")
    assert_equal '20150107', get_pay_day("201412",3).strftime("%Y%m%d") # payday:1,7
    assert_equal '20150206', get_pay_day("201501",3).strftime("%Y%m%d")
    assert_equal '20150605', get_pay_day("201505",3).strftime("%Y%m%d")
    assert_equal '20150107', get_pay_day("201502",7).strftime("%Y%m%d") # payday:-1,7
    assert_equal '20150206', get_pay_day("201503",7).strftime("%Y%m%d")
    assert_equal '20150605', get_pay_day("201507",7).strftime("%Y%m%d")
  end
  
  def test_get_tax_for_general
    employee_id = 8
    ym = 201707
    base_salary = 620000
    p = get_tax(ym, employee_id, base_salary, 0)
    e = Employee.find(employee_id)
    assert_equal "13", e.business_office.prefecture_code
    assert_equal 30721, p.insurance
  end

  def test_get_tax_for_care
    employee_id = 8
    ym = 201708
    base_salary = 620000
    p = get_tax(ym, employee_id, base_salary, 0)
    e = Employee.find(employee_id)
    assert_equal "13", e.business_office.prefecture_code
    assert_equal 35836, p.insurance
  end

  def test_get_tax_for_care_born_on_first
    employee_id = 9
    ym = 201707
    base_salary = 620000
    p = get_tax(ym, employee_id, base_salary, 0)
    e = Employee.find(employee_id)
    assert_equal "13", e.business_office.prefecture_code
    assert_equal 35836, p.insurance
  end

end
