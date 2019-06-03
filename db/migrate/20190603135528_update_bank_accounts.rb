class UpdateBankAccounts < ActiveRecord::Migration[5.2]
  BANK_ACCOUNT_ID_FOR_PAY = 1

  def up
    c = Company.where(deleted: false).first
    
    BankAccount.find_each do |ba|
      ba.company_id = c.id
      ba.for_payroll = ba.id == BANK_ACCOUNT_ID_FOR_PAY
      ba.save!
    end
  end
  
  def down
  end
end
