require 'test_helper'

class Hr::PayrollHelperTest < ActionView::TestCase
  
  def test_get_tax_for_general
    employee_id = 8
    e = Employee.find(employee_id)
    assert_equal '13', e.business_office.prefecture_code
    ym = 202506
    pay_day = get_pay_day(ym, e.id)

    judge_day = e.birth + 40.years - 1.day
    assert_equal 39, e.age_at(judge_day)
    assert pay_day.strftime('%Y%m') < judge_day.strftime('%Y%m') 

    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0, pay_day: pay_day)
    assert_equal 30721, p.health_insurance
  end

  def test_get_tax_for_care
    employee_id = 8
    e = Employee.find(employee_id)
    assert_equal '13', e.business_office.prefecture_code
    ym = 202507
    pay_day = get_pay_day(ym, e.id)

    judge_day = e.birth + 40.years - 1.day
    assert_equal 39, e.age_at(judge_day)
    assert pay_day.strftime('%Y%m') >= judge_day.strftime('%Y%m')

    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0, pay_day: pay_day)
    assert_equal 35650, p.health_insurance
  end

  def test_get_tax_for_care_born_on_first
    employee_id = 9
    e = Employee.find(employee_id)
    assert_equal "13", e.business_office.prefecture_code

    p = get_tax(202507, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 35650, p.health_insurance
  end

  def test_社会保険料は給与支給日を基準にして計算する
    # 厚生年金の保険料率改定前後をチェック
    ym = 201708
    employee_id = 1
    e = Employee.find(employee_id)
    assert_equal "0,25", e.company.pay_day_definition
    pay_day = get_pay_day(ym, 1)
    assert_equal "20170825", pay_day.strftime("%Y%m%d")
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31682, p.health_insurance
    assert_equal 56364, p.welfare_pension

    e.company.update!(pay_day_definition: "1,7")
    pay_day = get_pay_day(ym, 1)
    assert_equal "20170907", pay_day.strftime("%Y%m%d")
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31682, p.health_insurance
    assert_equal 56730, p.welfare_pension

    # 健康保険の保険料率改定前後をチェック
    ym = 202502
    e.company.update!(pay_day_definition: "0,25")
    pay_day = get_pay_day(ym, 1)
    assert_equal "20250225", pay_day.strftime("%Y%m%d")
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31651, p.health_insurance
    assert_equal 56730, p.welfare_pension

    e.company.update!(pay_day_definition: "1,7")
    pay_day = get_pay_day(ym, 1)
    assert_equal "20250307", pay_day.strftime("%Y%m%d")
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31961, p.health_insurance
    assert_equal 56730, p.welfare_pension
  end

end
