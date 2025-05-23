require 'test_helper'

class Hr::PayrollHelperTest < ActionView::TestCase
  
  def test_get_tax_for_general
    employee_id = 8
    e = Employee.find(employee_id)
    assert_equal '13', e.business_office.prefecture_code
    ym = 202507
    base_ym = e.company.get_base_ym_for_calc_social_insurance(ym)
    assert_equal 202507, base_ym

    judge_day = e.birth + 40.years - 1.day
    assert_equal 39, e.age_at(judge_day)
    assert base_ym < judge_day.strftime('%Y%m').to_i 

    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 30721, p.health_insurance
  end

  def test_get_tax_for_care
    employee_id = 8
    e = Employee.find(employee_id)
    assert_equal '13', e.business_office.prefecture_code
    ym = 202508
    base_ym = e.company.get_base_ym_for_calc_social_insurance(ym)
    assert_equal 202508, base_ym

    judge_day = e.birth + 40.years - 1.day
    assert_equal 39, e.age_at(judge_day)
    assert base_ym >= judge_day.strftime('%Y%m').to_i

    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 35650, p.health_insurance
  end

  def test_get_tax_for_care_born_on_first
    employee_id = 9
    e = Employee.find(employee_id)
    assert_equal "13", e.business_office.prefecture_code

    p = get_tax(202507, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 35650, p.health_insurance
  end

  def test_厚生年金の翌月徴収のチェック
    # 厚生年金の保険料率改定(2017年9月)前後をチェック
    ym = 201709
    employee_id = 1
    e = Employee.find(employee_id)
    assert_equal '0,25', e.company.pay_day_definition
    assert_equal 201708, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 56364, p.welfare_pension

    e.company.update!(pay_day_definition: '1,7')
    e.reload
    assert_equal 201709, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 56730, p.welfare_pension

    e.company.update!(pay_day_definition: '2,7')
    e.reload
    assert_equal 201710, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 56730, p.welfare_pension
  end

  def test_健康保険の翌月徴収のチェック
    # 健康保険の保険料率改定(2025年3月)前後をチェック
    ym = 202503
    employee_id = 1
    e = Employee.find(employee_id)
    assert_equal '0,25', e.company.pay_day_definition
    assert_equal 202502, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31651, p.health_insurance

    e.company.update!(pay_day_definition: '1,7')
    e.reload
    assert_equal '1,7', e.company.pay_day_definition
    assert_equal 202503, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31961, p.health_insurance

    e.company.update!(pay_day_definition: '2,7')
    e.reload
    assert_equal '2,7', e.company.pay_day_definition
    assert_equal 202504, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31961, p.health_insurance
  end

  def test_介護保険料の翌月徴収のチェック
    # 介護保険料の適用開始月前後をチェック
    employee_id = 8
    e = Employee.find(8)
    judge_day = e.birth + 40.years - 1.day
    assert_equal 39, e.age_at(judge_day)
    assert_equal 202508, judge_day.strftime('%Y%m').to_i
    ym = 202508

    e.company.update!(pay_day_definition: '0,25')
    e.reload
    assert_equal '0,25', e.company.pay_day_definition
    assert_equal 202507, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_not p.care_applicable?
    assert_equal 30721, p.health_insurance

    e.company.update!(pay_day_definition: '1,7')
    e.reload
    assert_equal '1,7', e.company.pay_day_definition
    assert_equal 202508, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert p.care_applicable?
    assert_equal 35650, p.health_insurance

    e.company.update!(pay_day_definition: '2,7')
    e.reload
    assert_equal '2,7', e.company.pay_day_definition
    assert_equal 202509, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert p.care_applicable?
    assert_equal 35650, p.health_insurance
  end

  def test_厚生年金の翌月徴収のチェック_給与支給日を翌月払いに固定
    # 厚生年金の保険料率改定(2017年9月)前後をチェック
    employee_id = 1
    e = Employee.find(employee_id)
    e.company.update!(pay_day_definition: '1,7')
    e.reload
    assert_equal '1,7', e.company.pay_day_definition

    ym = 201708
    assert_equal 201708, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 56364, p.welfare_pension

    ym = 201709
    assert_equal 201709, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 56730, p.welfare_pension

    ym = 201710
    assert_equal 201710, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 56730, p.welfare_pension
  end

  def test_健康保険の翌月徴収のチェック_給与支給日を翌月払いに固定
    # 健康保険の保険料率改定(2025年3月)前後をチェック
    employee_id = 1
    e = Employee.find(employee_id)
    e.company.update!(pay_day_definition: '1,7')
    e.reload
    assert_equal '1,7', e.company.pay_day_definition
    
    ym = 202502
    assert_equal 202502, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31651, p.health_insurance
    
    ym = 202503
    assert_equal 202503, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31961, p.health_insurance

    ym = 202504
    assert_equal 202504, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31961, p.health_insurance
  end

  def test_介護保険料の翌月徴収のチェック_給与支給日を翌月払いに固定
    # 介護保険料の適用開始月前後をチェック
    employee_id = 8
    e = Employee.find(employee_id)
    assert_equal '1,7', e.company.pay_day_definition
    judge_day = e.birth + 40.years - 1.day
    assert_equal 39, e.age_at(judge_day)
    assert_equal 202508, judge_day.strftime('%Y%m').to_i
    
    ym = 202507
    assert_equal 202507, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_not p.care_applicable?
    assert_equal 30721, p.health_insurance

    ym = 202508
    assert_equal 202508, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert p.care_applicable?
    assert_equal 35650, p.health_insurance

    ym = 202509
    assert_equal 202509, e.company.get_base_ym_for_calc_social_insurance(ym)
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert p.care_applicable?
    assert_equal 35650, p.health_insurance
  end

end
