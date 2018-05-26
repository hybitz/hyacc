class UpdatePayDayOnPayrolls < ActiveRecord::Migration[5.1]

  def up
    Payroll.order('employee_id, ym').each do |p|
      pay_day = p.pay_journal_header.date
      puts "#{p.ym}: #{p.employee.fullname} => #{pay_day}"
      p.update_column :pay_day, pay_day
    end
  end
  
  def down
  end
end
