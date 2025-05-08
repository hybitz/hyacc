require 'test_helper'

class PayrollTest < ActiveSupport::TestCase
  
  def test_get_previous_base_salary
    @payroll = Payroll.find(70)
    assert_equal 394000, @payroll.base_salary

    date = (@payroll.payroll_journal.date + 1.month).strftime('%Y%m')
    employee = @payroll.employee
    assert_equal 394000, Payroll.get_previous(date, employee.id).base_salary
  end

  def test_その他調整額
    e = employee
    assert_not e.executive?
    fy = e.company.fiscal_years.find_or_initialize_by(fiscal_year: 2024)
    fy.closing_status = CLOSING_STATUS_OPEN
    assert fy.save, fy.errors.full_messages
    
    p = Payroll.new(ym: 202404, pay_day: '2024-05-07', employee: e, base_salary: 300_000, monthly_standard: 300_000)
    p.create_user_id = p.update_user_id = e.id
    p.misc_adjustment_note = 'その他調整額テスト'
    p.misc_adjustment = 50_000
    assert p.save, p.errors.full_messages

    assert pd = p.payroll_journal
    assert_equal 300_000, pd.get_debit_amount(ACCOUNT_CODE_SALARY)
    assert_equal 50_000, pd.get_debit_amount(ACCOUNT_CODE_SUSPENSE_RECEIPT_EMPLOYEE)
    assert_equal 350_000, pd.get_credit_amount(ACCOUNT_CODE_ACCRUED_EXPENSE_EMPLOYEE)
  end

  def test_差引合計額
    p = Payroll.new(ym: 202404, pay_day: '2024-05-07', base_salary: 300_000, misc_adjustment: 100_000)
    assert_equal 400_000, p.pay_total
  end

  def test_社会保険料
    e = employee
    fy = e.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.closing_status = CLOSING_STATUS_OPEN

    assert 0.25, e.company.pay_day_definition
    ym = 202502
    pay_day = e.company.get_actual_pay_day_for(ym)

    p1 = Payroll.new(ym: ym, pay_day: pay_day, employee: e, base_salary: 300_000, monthly_standard: 300_000)
    p1.create_user_id = p1.update_user_id = e.id

    ym = 202503
    pay_day = e.company.get_actual_pay_day_for(ym)
    p2 = Payroll.new(ym: ym, pay_day: pay_day, employee: e, base_salary: 300_000, monthly_standard: 300_000)
    p2.create_user_id = p2.update_user_id = e.id

    assert_not p1.care_applicable?
    p1.calc_social_insurance
    assert_equal 15315, p1.health_insurance
    assert_equal 27450, p1.welfare_pension

    assert_not p2.care_applicable?
    p2.calc_social_insurance
    assert_equal 15465, p2.health_insurance
    assert_equal 27450, p2.welfare_pension

    e.update!(birth: '1985-01-01')
    p1.employee = e
    p2.employee = e
    
    assert p1.care_applicable?
    p1.calc_social_insurance
    assert_equal 17715, p1.health_insurance
    assert_equal 27450, p1.welfare_pension

    assert p2.care_applicable?
    p2.calc_social_insurance
    assert_equal 17850, p2.health_insurance
    assert_equal 27450, p2.welfare_pension
  end

  def test_雇用保険料
    e = employee
    assert_not e.executive?
    fy = e.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.closing_status = CLOSING_STATUS_OPEN

    p1 = Payroll.new(ym: 202503, pay_day: '2025-04-07', employee: e, base_salary: 300_000, monthly_standard: 300_000)
    p1.create_user_id = p1.update_user_id = e.id

    p2 = Payroll.new(ym: 202504, pay_day: '2025-05-07', employee: e, base_salary: 300_000, monthly_standard: 300_000)
    p2.create_user_id = p2.update_user_id = e.id

    p1.calc_employment_insurance
    assert_equal 1800, p1.employment_insurance

    p2.calc_employment_insurance
    assert_equal 1650, p2.employment_insurance

    e.update!(executive: true)
    p1.employee = e
    p1.calc_employment_insurance
    assert_equal 0, p1.employment_insurance

    p2.employee = e
    p2.calc_employment_insurance
    assert_equal 0, p2.employment_insurance
  end

end