class UpdateDisabledOnBankOffices < ActiveRecord::Migration
  def up
    BankOffice.find_each do |bo|
      raise 'error' unless bo.update_column(:disabled, bo.deleted)
    end
  end

  def down
  end
end
