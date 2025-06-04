require 'test_helper'

class Hr::PayrollHelperTest < ActionView::TestCase
  
  def test_get_tax_for_general
    employee_id = 8
    e = Employee.find(employee_id)
    assert_equal '13', e.business_office.prefecture_code
    ym = 202507

    judge_day = e.birth + 40.years - 1.day
    assert_equal 39, e.age_at(judge_day)
    assert ym < judge_day.strftime('%Y%m').to_i 

    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 30721, p.health_insurance
  end

  def test_get_tax_for_care
    employee_id = 8
    e = Employee.find(employee_id)
    assert_equal '13', e.business_office.prefecture_code
    ym = 202508

    judge_day = e.birth + 40.years - 1.day
    assert_equal 39, e.age_at(judge_day)
    assert ym >= judge_day.strftime('%Y%m').to_i

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

  def test_厚生年金の翌月徴収のチェック_給与支給日を翌月払いに固定
    # 厚生年金の保険料率改定(2017年9月)前後をチェック
    employee_id = 1
    e = Employee.find(employee_id)
    e.company.update!(pay_day_definition: '1,7')
    e.reload
    assert_equal '1,7', e.company.pay_day_definition

    ym = 201708
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 56364, p.welfare_pension

    ym = 201709
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 56730, p.welfare_pension

    ym = 201710
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
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31651, p.health_insurance
    
    ym = 202503
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_equal 31961, p.health_insurance

    ym = 202504
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
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert_not p.care_applicable?
    assert_equal 30721, p.health_insurance

    ym = 202508
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert p.care_applicable?
    assert_equal 35650, p.health_insurance

    ym = 202509
    p = get_tax(ym, employee_id, 620000, 620000, 0, 0, 0)
    assert p.care_applicable?
    assert_equal 35650, p.health_insurance
  end

  def test_get_standard_remuneration_入社3ヵ月未満
    # 入社3ヶ月未満の場合は資格取得時の標準報酬月額を使う
    employee_id = 8
    employment_ym = 202507
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}01"))
    e = Employee.find(employee_id)
    Payroll.where('employee_id = ? and ym < ?', employee_id, employment_ym).delete_all
    Payroll.where('employee_id = ? and ym >= ?', employee_id, employment_ym).update_all(monthly_standard: 320000)
    
    # 入社3ヵ月目
    ym = 202509
    ym_1 = (Date.new(ym/100, ym%100, 1) << 1).strftime("%Y%m")
    ym_2 = (Date.new(ym/100, ym%100, 1) << 2).strftime("%Y%m")
    ym_3 = (Date.new(ym/100, ym%100, 1) << 3).strftime("%Y%m")
    pr_1 = Payroll.find_by_ym_and_employee_id(ym_1, employee_id)
    pr_2 = Payroll.find_by_ym_and_employee_id(ym_2, employee_id)
    pr_3 = Payroll.find_by_ym_and_employee_id(ym_3, employee_id)
    assert pr_3.new_record?
    assert pr_2.persisted?
    assert_equal 320000, pr_2.monthly_standard
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)
    # 入社2ヵ月目
    ym = 202508
    ym_1 = (Date.new(ym/100, ym%100, 1) << 1).strftime("%Y%m")
    ym_2 = (Date.new(ym/100, ym%100, 1) << 2).strftime("%Y%m")
    ym_3 = (Date.new(ym/100, ym%100, 1) << 3).strftime("%Y%m")
    pr_1 = Payroll.find_by_ym_and_employee_id(ym_1, employee_id)
    pr_2 = Payroll.find_by_ym_and_employee_id(ym_2, employee_id)
    pr_3 = Payroll.find_by_ym_and_employee_id(ym_3, employee_id)
    assert pr_3.new_record?
    assert_not pr_2.persisted?
    assert pr_1.persisted?
    assert_equal 320000, pr_1.monthly_standard
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)
  end

  def test_get_standard_remuneration_9月分の標準報酬月額
    # 3月1日より前に入社
    employee_id = 8
    ym = 202509
    e = Employee.find(employee_id)
    y = (ym.to_s).slice(0, 4).to_i
    x = (y.to_s + "03").to_i

    Payroll.where(employee_id: employee_id, ym: x).update_all(extra_pay: 70000) 
    Payroll.where(employee_id: employee_id, ym: x + 2).update_all(extra_pay: 20000)

    pr = Payroll.find_by_ym_and_employee_id(x, employee_id)
    pr1 = Payroll.find_by_ym_and_employee_id(x + 1, employee_id)
    pr2 = Payroll.find_by_ym_and_employee_id(x + 2, employee_id)

    assert_equal 380000, pr.salary_subtotal
    assert_equal 310000, pr1.salary_subtotal
    assert_equal 330000, pr2.salary_subtotal
    assert_equal 340000, TaxUtils.get_basic_info(ym, 13,
      (pr.salary_subtotal + pr1.salary_subtotal + pr2.salary_subtotal)/3).monthly_standard
    assert_equal 340000, get_standard_remuneration(ym, e, 310000)
    
    # 3月1日入社
    employment_ym = 202503
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}01"))
    e = Employee.find(employee_id)
    assert_equal 340000, get_standard_remuneration(ym, e, 310000)

    # 3月中途入社
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}15"))
    e = Employee.find(employee_id)
    assert_equal 320000, TaxUtils.get_basic_info(ym, 13,
      (pr1.salary_subtotal + pr2.salary_subtotal)/2).monthly_standard
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)

    # 4月1日入社
    employment_ym = 202504
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}01"))
    e = Employee.find(employee_id)
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)

    # 4月途中入社
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}15"))
    e = Employee.find(employee_id)
    assert_equal 340000, TaxUtils.get_basic_info(ym, 13, pr2.salary_subtotal).monthly_standard    
    assert_equal 340000, get_standard_remuneration(ym, e, 350000)
    
    # 5月1日入社
    employment_ym = 202505
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}01"))
    e = Employee.find(employee_id)
    assert_equal 340000, get_standard_remuneration(ym, e, 310000)

    # 5月途中入社の場合は資格取得時の標準報酬月額を使う
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}15"))
    e = Employee.find(employee_id)
    Payroll.where(employee_id: employee_id, ym: employment_ym).update_all(monthly_standard: 320000)
    pr = Payroll.find_by_ym_and_employee_id(employment_ym, employee_id)
    assert_equal 320000, pr.monthly_standard
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)

    # 6月以降入社の場合は資格取得時の標準報酬月額を使う
    employment_ym = 202506
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}01"))
    e = Employee.find(employee_id)
    Payroll.where(employee_id: employee_id, ym: employment_ym).update_all(monthly_standard: 320000)
    pr = Payroll.find_by_ym_and_employee_id(employment_ym, employee_id)
    assert_equal 320000, pr.monthly_standard
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)
  end

  def test_get_standard_remuneration_8月分の標準報酬月額
    # 前年の3月1日より前に入社
    employee_id = 8
    ym = 202508
    e = Employee.find(employee_id)
    y = (ym.to_s).slice(0, 4).to_i - 1
    x = (y.to_s + "03").to_i

    Payroll.where(employee_id: employee_id, ym: x).update_all(extra_pay: 50000) 
    Payroll.where(employee_id: employee_id, ym: x + 2).update_all(extra_pay: 10000)

    pr = Payroll.find_by_ym_and_employee_id(x, employee_id)
    pr1 = Payroll.find_by_ym_and_employee_id(x + 1, employee_id)
    pr2 = Payroll.find_by_ym_and_employee_id(x + 2, employee_id)

    assert_equal 350000, pr.salary_subtotal
    assert_equal 300000, pr1.salary_subtotal
    assert_equal 310000, pr2.salary_subtotal
    assert_equal 320000, TaxUtils.get_basic_info(ym, 13,
      (pr.salary_subtotal + pr1.salary_subtotal + pr2.salary_subtotal)/3).monthly_standard
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)
    
    # 前年の3月1日入社
    employment_ym = 202403
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}01"))
    e = Employee.find(employee_id)
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)

    # 前年の3月中途入社
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}15"))
    e = Employee.find(employee_id)
    assert_equal 300000, TaxUtils.get_basic_info(ym, 13,
      (pr1.salary_subtotal + pr2.salary_subtotal)/2).monthly_standard
    assert_equal 300000, get_standard_remuneration(ym, e, 310000)

    # 前年の4月1日入社
    employment_ym = 202404
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}01"))
    e = Employee.find(employee_id)
    assert_equal 300000, get_standard_remuneration(ym, e, 310000)

    # 前年の4月途中入社
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}15"))
    e = Employee.find(employee_id)
    assert_equal 320000, TaxUtils.get_basic_info(ym, 13, pr2.salary_subtotal).monthly_standard
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)
    
    # 前年の5月1日入社
    employment_ym = 202405
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}01"))
    e = Employee.find(employee_id)
    assert_equal 320000, get_standard_remuneration(ym, e, 310000)

    # 前年の5月途中入社の場合は資格取得時の標準報酬月額を使う（随時改定が発生しない場合）
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}15"))
    e = Employee.find(employee_id)
    Payroll.where(employee_id: employee_id, ym: employment_ym).update_all(monthly_standard: 300000)
    pr = Payroll.find_by_ym_and_employee_id(employment_ym, employee_id)
    assert_equal 300000, pr.monthly_standard
    assert_equal 300000, get_standard_remuneration(ym, e, 310000)

    # 前年の6月以降入社の場合は資格取得時の標準報酬月額を使う（随時改定が発生しない場合）
    employment_ym = 202406
    Employee.find(employee_id).update!(employment_date: Date.parse("#{employment_ym}01"))
    e = Employee.find(employee_id)
    Payroll.where(employee_id: employee_id, ym: employment_ym).update_all(monthly_standard: 300000)
    pr = Payroll.find_by_ym_and_employee_id(employment_ym, employee_id)
    assert_equal 300000, pr.monthly_standard
    assert_equal 300000, get_standard_remuneration(ym, e, 310000)
  end

  def test_get_standard_remuneration_随時改定
    employee_id = 8
    ym = 202508
    e = Employee.find(employee_id)
    assert_equal 300000, get_standard_remuneration(ym, e, 310000)
    
    y = 202407
    # 随時改定が発生する場合（変動月は固定的賃金の変動で発生）
    Payroll.where(employee_id: employee_id, ym: y).update_all(housing_allowance: 40000)
    Payroll.where(employee_id: employee_id, ym: y + 1).update_all(housing_allowance: 40000)
    Payroll.where(employee_id: employee_id, ym: y + 2).update_all(housing_allowance: 40000)

    pre_pr = Payroll.find_by_ym_and_employee_id(y - 1, employee_id)
    pr = Payroll.find_by_ym_and_employee_id(y, employee_id)
    pr1 = Payroll.find_by_ym_and_employee_id(y + 1, employee_id)
    pr2 = Payroll.find_by_ym_and_employee_id(y + 2, employee_id)

    assert_equal 300000, pre_pr.salary_subtotal - pre_pr.extra_pay
    assert_equal 340000, pr.salary_subtotal - pr.extra_pay
    assert_equal 340000, pr1.salary_subtotal - pr.extra_pay
    assert_equal 340000, pr2.salary_subtotal - pr.extra_pay
    assert_equal 340000, TaxUtils.get_basic_info(ym, 13, 340000).monthly_standard

    # 随時改定が発生しない場合（変動月は非固定的賃金の変動では発生しない）
    Payroll.where(employee_id: employee_id, ym: y).update_all(housing_allowance: 0, extra_pay: 40000)
    Payroll.where(employee_id: employee_id, ym: y + 1).update_all(housing_allowance: 0, extra_pay: 40000)
    Payroll.where(employee_id: employee_id, ym: y + 2).update_all(housing_allowance: 0, extra_pay: 40000)

    pre_pr = Payroll.find_by_ym_and_employee_id(y - 1, employee_id)
    pr = Payroll.find_by_ym_and_employee_id(y, employee_id)
    pr1 = Payroll.find_by_ym_and_employee_id(y + 1, employee_id)
    pr2 = Payroll.find_by_ym_and_employee_id(y + 2, employee_id)

    assert_equal 300000, pre_pr.salary_subtotal - pre_pr.extra_pay
    assert_equal 300000, pr.salary_subtotal - pr.extra_pay
    assert_equal 300000, pr1.salary_subtotal - pr.extra_pay
    assert_equal 300000, pr2.salary_subtotal - pr.extra_pay
    assert_equal 300000, get_standard_remuneration(ym, e, 350000)
  end
end
