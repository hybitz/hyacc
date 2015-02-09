module Payrolls

  def payroll
    @_payroll ||= Payroll.first
  end

  def valid_payroll_params(attrs = {})
    ret = {
      :ym => attrs[:ym] || payroll.ym,
      :employee_id => attrs[:employee_id] || payroll.employee_id,
      :days_of_work => 28,
      :hours_of_work => 224,
      :hours_of_day_off_work => 100,
      :hours_of_early_for_work => 101,
      :hours_of_late_night_work => 102,
      :base_salary => '394000',
      :insurance => '10000',
      :pension => '20000',
      :income_tax => '1000',
      :inhabitant_tax => '8400',
      :accrued_liability => '120000',
      :pay_day => '2009-03-06',
      :credit_account_type_of_income_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
      :credit_account_type_of_insurance => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
      :credit_account_type_of_pension => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY,
      :credit_account_type_of_inhabitant_tax => Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY
    }
  end

end