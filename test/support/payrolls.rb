module Payrolls

  def payroll
    @_payroll ||= Payroll.first
  end

  def payroll_params(attrs = {})
    ret = {
      ym: attrs[:ym] || payroll.ym,
      employee_id: attrs[:employee_id] || payroll.employee_id,
      days_of_work: 28,
      hours_of_work: 224,
      hours_of_day_off_work: 100,
      hours_of_early_work: 101,
      hours_of_late_night_work: 102,
      base_salary: '394000',
      health_insurance: '10000',
      welfare_pension: '20000',
      income_tax: '1000',
      inhabitant_tax: '8400',
      accrued_liability: attrs.fetch(:accrued_liability, 0),
      pay_day: '2009-03-06',
      transfer_fee: 500,
      misc_adjustment: 0,
      misc_adjustment_note: ''
    }
  end

end
