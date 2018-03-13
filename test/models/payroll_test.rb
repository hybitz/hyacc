require 'test_helper'

class PayrollTest < ActiveSupport::TestCase
  
  def test_create
    @payroll = Payroll.find(45)

    fix_payroll = payrolls(:payroll_00045)
    assert_equal fix_payroll["ym"], @payroll.ym
    assert_equal fix_payroll["employee_id"], @payroll.employee_id
    assert_equal fix_payroll["payroll_journal_header_id"], @payroll.payroll_journal_header_id
    assert_equal fix_payroll["pay_journal_header_id"], @payroll.pay_journal_header_id
    assert_equal fix_payroll["days_of_work"], @payroll.days_of_work
    assert_equal fix_payroll["hours_of_work"], @payroll.hours_of_work
    assert_equal fix_payroll["hours_of_day_off_work"], @payroll.hours_of_day_off_work
    assert_equal fix_payroll["hours_of_early_work"], @payroll.hours_of_early_work
    assert_equal fix_payroll["hours_of_late_night_work"], @payroll.hours_of_late_night_work
  end

  def test_get_previous_base_salary
    @payroll = Payroll.find(70)
    assert_equal 394000, @payroll.get_base_salary_from_jd

    date = (@payroll.payroll_journal_header.date + 1.month).strftime('%Y%m')
    employee = @payroll.employee
    assert_equal 394000, Payroll.get_previous_base_salary(date, employee.id)
  end
end
