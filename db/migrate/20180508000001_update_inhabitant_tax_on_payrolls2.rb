class UpdateInhabitantTaxOnPayrolls2 < ActiveRecord::Migration[5.1]
  include HyaccConst
  
  CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED = '0'
  CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY = '1'

  def up
    Payroll.order('employee_id, ym').each do |p|
      it = get_inhabitant_tax_from_jd(p)
      next if it == 0
  
      puts "#{p.ym}: #{p.employee.fullname} => #{it}"
      p.update_column :inhabitant_tax, it
    end
  end
  
  def down
  end

  def get_inhabitant_tax_from_jd(payroll)
    if payroll.credit_account_type_of_inhabitant_tax == CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
      return payroll.payroll_journal_header.get_credit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_INHABITANT_TAX)
    elsif payroll.credit_account_type_of_inhabitant_tax == CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY
      return payroll.payroll_journal_header.get_credit_amount(ACCOUNT_CODE_ADVANCE_MONEY, SUB_ACCOUNT_CODE_INHABITANT_TAX)
    end
  end
end
