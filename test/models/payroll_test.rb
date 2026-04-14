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

  def test_find_or_initialize_regular_payroll
    e = Employee.find(8)
    ym = 202508
    p = Payroll.find_by(ym: ym, employee_id: e.id, is_bonus: false)
    p1 = Payroll.find_or_initialize_regular_payroll(ym, e.id)
    assert_equal p.id, p1.id

    ym = 202511
    assert_nil Payroll.find_by(ym: ym, employee_id: e.id, is_bonus: false)
    p2 = Payroll.find_or_initialize_regular_payroll(ym, e.id)
    assert p2.new_record?
    assert_not p2.is_bonus?
  end

  def test_health_standard_bonus_basis_of
    p = Payroll.new(temporary_salary: 1_000_000)
    sh = Payroll.health_standard_bonus_basis_of(p)
    assert_equal 1_000_000, sh
    assert_equal 0, Payroll.health_standard_bonus_basis_of(nil)
  end

  def test_health_standard_bonus_basis_of_賞与額が上限超えでも上限で頭打ち
    p = Payroll.new(temporary_salary: 6_000_000)
    sh = Payroll.health_standard_bonus_basis_of(p)
    assert_equal Payroll::BONUS_STANDARD_ANNUAL_MAX_FOR_HEALTH, sh
  end

  def test_bonus_標準賞与額_厚生年金は150万で頭打ちされ健康保険はそれ以上も算定
    e = employee
    p = Payroll.new(
      is_bonus: true, temporary_salary: 2_000_000,
      employee: e, pay_day: Date.new(2025, 6, 10)
    )
    p.calc_social_insurance
    p_at_max = Payroll.new(
      is_bonus: true, temporary_salary: 1_500_000,
      employee: e, pay_day: Date.new(2025, 7, 10)
    )
    p_at_max.calc_social_insurance
    assert_equal p_at_max.welfare_pension, p.welfare_pension
    assert p.health_insurance > p_at_max.health_insurance
  end

  def test_bonus_標準賞与額の年度上限到達後は子ども子育て支援金も健康保険と同様にゼロ算定
    e = employee
    prior = payrolls(:payroll_bonus_health_max_prior)
    current = Payroll.new(
      ym: 202605,
      is_bonus: true, temporary_salary: 1_000_000,
      employee: e, pay_day: Date.new(2026, 6, 10)
    )
    current.calc_social_insurance
    assert_equal 0, current.health_insurance
    assert_equal 0, current.child_and_childcare_support

    reference = Payroll.new(
      ym: 202605,
      is_bonus: true, temporary_salary: 1_000_000,
      employee: Employee.find(2), pay_day: Date.new(2026, 6, 10)
    )
    reference.calc_social_insurance
    assert_equal prior.id, current.send(:prior_bonus_payroll_same_insurance_year).id
    assert reference.health_insurance > 0
    assert reference.child_and_childcare_support > 0
  end

  def test_bonus_同一保険年度に150万円超の過去賞与があっても当月厚生年金は影響を受けない
    prior_over_max = Payroll.find_by!(
      employee_id: 8, ym: 202604, is_bonus: true
    )
    with_prior = Payroll.find_by!(
      employee_id: 8, ym: 202605, is_bonus: true, temporary_salary: 800_000
    )
    without_prior = Payroll.find_by!(
      employee_id: 9, ym: 202605, is_bonus: true, temporary_salary: 800_000
    )

    assert prior_over_max.temporary_salary > Payroll::BONUS_STANDARD_MAX_FOR_WELFARE_PENSION
    with_prior.calc_social_insurance
    without_prior.calc_social_insurance

    assert_equal with_prior.welfare_pension, without_prior.welfare_pension
  end

end
