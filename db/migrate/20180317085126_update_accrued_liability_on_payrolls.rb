class UpdateAccruedLiabilityOnPayrolls < ActiveRecord::Migration[5.1]
  include HyaccConstants

  def up
    Payroll.order('employee_id, ym').each do |p|
      accrued_liability = get_accrued_liability_from_jd(p)

      puts "#{p.ym}: #{p.employee.fullname} => #{accrued_liability}"
      p.update_column :accrued_liability, accrued_liability
    end
  end
  
  def down
  end
  
  def get_accrued_liability_from_jd(payroll)
    payroll.pay_journal_header.get_debit_amount(ACCOUNT_CODE_UNPAID_EMPLOYEE)
  end
end
