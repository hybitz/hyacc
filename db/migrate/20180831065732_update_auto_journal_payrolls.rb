class UpdateAutoJournalPayrolls < ActiveRecord::Migration[5.2]
  def up
    Payroll.find_each do |p|
      j = Journal.find_by_id(p.payroll_journal_id)
      if j
        j.payroll_id = p.id
        j.type = Auto::Journal::Payroll.name
        j.save!
      end

      j = Journal.find_by_id(p.pay_journal_id)
      if j
        j.payroll_id = p.id
        j.type = Auto::Journal::PayrollPay.name
        j.save!
      end

      j = Journal.find_by_id(p.commission_journal_id)
      if j
        j.payroll_id = p.id
        j.type = Auto::Journal::PayrollCommission.name
        j.save!
      end
    end
  end
end
