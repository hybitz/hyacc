class UpdateAutoJournalPayrolls < ActiveRecord::Migration[5.2]
  def up
    Payroll.find_each do |p|
      j = p.payroll_journal
      j.payroll_id = p.id
      j.type = Auto::Journal::Payroll.name
      j.save!

      j = p.pay_journal
      j.payroll_id = p.id
      j.type = Auto::Journal::PayrollPay.name
      j.save!

      j = p.commission_journal
      if j
        j.payroll_id = p.id
        j.type = Auto::Journal::PayrollCommission.name
        j.save!
      end
    end
  end
end
