require 'test_helper'

class Hr::PayrollHelperTest < ActionView::TestCase
  
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
    e = Employee.find(employee_id)
    assert_equal "13", e.business_office.prefecture_code
    ym = 202507
    pay_day = get_pay_day(ym, 8) 
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0, pay_day)
    assert_equal 30721, p.health_insurance
  end

  def test_get_tax_for_care
    employee_id = 8
    e = Employee.find(employee_id)
    assert_equal "13", e.business_office.prefecture_code
    ym = 202508
    pay_day = get_pay_day(ym, 8) 
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0, pay_day)
    assert_equal 35650, p.health_insurance
  end

  def test_get_tax_for_care_born_on_first
    employee_id = 9
    e = Employee.find(employee_id)
    assert_equal "13", e.business_office.prefecture_code

    ym = 202507
    pay_day = get_pay_day(ym, 9)  
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0, pay_day)
    assert_equal 35650, p.health_insurance
  end

  def test_社会保険料は給与支給日を基準にして計算する
    # 厚生年金の保険料率改定前後をチェック
    ym = 201708
    employee_id = 1
    e = Employee.find(employee_id)
    assert_equal "0,25", e.company.payday
    pay_day = get_pay_day(ym, 1)
    assert_equal "20170825", pay_day.strftime("%Y%m%d")
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0, pay_day)
    assert_equal 31682, p.health_insurance
    assert_equal 56364, p.welfare_pension

    e.company.update!(payday: "1,7")
    pay_day = get_pay_day(ym, 1)
    assert_equal "20170907", pay_day.strftime("%Y%m%d")
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0, pay_day)
    assert_equal 31682, p.health_insurance
    assert_equal 56730, p.welfare_pension

    # 健康保険の保険料率改定前後をチェック
    ym = 202502
    e.company.update!(payday: "0,25")
    pay_day = get_pay_day(ym, 1)
    assert_equal "20250225", pay_day.strftime("%Y%m%d")
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0, pay_day)
    assert_equal 31651, p.health_insurance
    assert_equal 56730, p.welfare_pension

    e.company.update!(payday: "1,7")
    pay_day = get_pay_day(ym, 1)
    assert_equal "20250307", pay_day.strftime("%Y%m%d")
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0, pay_day)
    assert_equal 31961, p.health_insurance
    assert_equal 56730, p.welfare_pension
  end

end
