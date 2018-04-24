class UpdateHealthInsuranceOnPayrolls < ActiveRecord::Migration[5.1]
  include HyaccConstants
  
  CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED = '0'
  CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY = '1'

  def up
    Payroll.order('employee_id, ym').each do |p|
      hi = get_insurance_from_jd(p)
      next if hi == 0
  
      puts "#{p.ym}: #{p.employee.fullname} => #{hi}"
      p.update_column :health_insurance, hi
    end
  end
  
  def down
  end

  def get_insurance_from_jd(payroll)
    if payroll.credit_account_type_of_insurance == CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
      return payroll.payroll_journal_header.get_credit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_HEALTH_INSURANCE)
    elsif payroll.credit_account_type_of_insurance == CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY
      return payroll.payroll_journal_header.get_credit_amount(ACCOUNT_CODE_ADVANCE_MONEY, SUB_ACCOUNT_CODE_HEALTH_INSURANCE)
    end
  end
end
