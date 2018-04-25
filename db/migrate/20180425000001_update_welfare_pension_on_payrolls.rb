class UpdateWelfarePensionOnPayrolls < ActiveRecord::Migration[5.1]
  include HyaccConstants
  
  CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED = '0'
  CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY = '1'

  def up
    Payroll.order('employee_id, ym').each do |p|
      wp = get_pension_from_jd(p)
      next if wp == 0
  
      puts "#{p.ym}: #{p.employee.fullname} => #{wp}"
      p.update_column :welfare_pension, wp
    end
  end
  
  def down
  end

  def get_pension_from_jd(payroll)
    payroll.payroll_journal_header.get_credit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_EMPLOYEES_PENSION)
  end
end
