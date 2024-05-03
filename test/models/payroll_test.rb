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
    pd.journal_details.each do |jd|
      puts
      puts jd.attributes.sort.map(&:to_s)
    end
    assert_equal 300_000, pd.get_debit_amount(ACCOUNT_CODE_SALARY)
    assert_equal 50_000, pd.get_debit_amount(ACCOUNT_CODE_SUSPENSE_RECEIPT_EMPLOYEE)
    assert_equal 350_000, pd.get_credit_amount(ACCOUNT_CODE_ACCRUED_EXPENSE_EMPLOYEE)
  end

end
