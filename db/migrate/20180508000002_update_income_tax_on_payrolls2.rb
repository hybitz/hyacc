class UpdateIncomeTaxOnPayrolls2 < ActiveRecord::Migration[5.1]
  include HyaccConstants
  
  CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED = '0'
  CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY = '1'

  def up
    Payroll.order('employee_id, ym').each do |p|
      it = get_income_tax_from_jd(p)
      next if it == 0
  
      puts "#{p.ym}: #{p.employee.fullname} => #{it}"
      p.update_column :income_tax, it
    end
  end
  
  def down
  end

  def get_income_tax_from_jd(payroll)
    payroll.payroll_journal_header.get_credit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_INCOME_TAX)
  end
end
