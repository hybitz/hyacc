class UpdateBaseSalaryOnPayrolls < ActiveRecord::Migration[5.1]
  include HyaccConstants

  def up
    Payroll.order('employee_id, ym').each do |p|
      base_salary = p.is_bonus? ? get_base_bonus_from_jd(p) : get_base_salary_from_jd(p)
      puts "#{p.ym}: #{p.employee.fullname} => #{base_salary}"
      p.update_column :base_salary, base_salary
    end
  end
  
  def down
  end
  
  def get_base_salary_from_jd(payroll)
    ret = payroll.payroll_journal_header.get_debit_amount(ACCOUNT_CODE_DIRECTOR_SALARY)
    ret += payroll.payroll_journal_header.get_debit_amount(ACCOUNT_CODE_SALARY)
  end

  def get_base_bonus_from_jd(payroll)
    payroll.payroll_journal_header.get_debit_amount(ACCOUNT_CODE_ACCRUED_DIRECTOR_BONUS)
  end
end
