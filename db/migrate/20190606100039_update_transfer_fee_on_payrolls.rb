class UpdateTransferFeeOnPayrolls < ActiveRecord::Migration[5.2]
  include HyaccConstants
  
  def up
    Payroll.order('employee_id, ym').each do |p|
      tf = get_transfer_fee(p)
  
      puts "#{p.ym}: #{p.employee.fullname} => #{tf}"
      p.update_column :transfer_fee, tf
    end
  end
  
  def down
  end
  
  def get_transfer_fee(payroll)
    details = payroll.commission_journal.try(:journal_details) || []
    details.first.try(:amount).to_i
  end
end
