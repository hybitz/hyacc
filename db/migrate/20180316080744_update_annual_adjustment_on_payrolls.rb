class UpdateAnnualAdjustmentOnPayrolls < ActiveRecord::Migration[5.1]
  include HyaccConstants
  
  def up
    Payroll.order('employee_id, ym').each do |p|
      annual_adjustment = get_year_end_adjustment_liability_from_jd(p)
      next if annual_adjustment == 0

      puts "#{p.ym}: #{p.employee.fullname} => #{annual_adjustment}"
      p.update_column :annual_adjustment, annual_adjustment
    end
  end
  
  def down
  end

  def get_year_end_adjustment_liability_from_jd(payroll)
    payroll.payroll_journal_header.get_debit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_INCOME_TAX)
  end
end
