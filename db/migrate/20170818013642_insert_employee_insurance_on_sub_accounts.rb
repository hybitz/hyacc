class InsertEmployeeInsuranceOnSubAccounts < ActiveRecord::Migration[5.0]
include HyaccConstants
  def self.up
    SubAccount.transaction do
      a = Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY)
      sa = SubAccount.new( :code => SUB_ACCOUNT_CODE_EMPLOYEES_INSURANCE_OF_ADVANCE_MONEY, :name => '雇用保険料' )
      sa.account = a
      sa.save!
      a = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
      sa = SubAccount.new( :code => SUB_ACCOUNT_CODE_EMPLOYEES_INSURANCE_OF_DEPOSITS_RECEIVED, :name => '雇用保険料' )
      sa.account = a
      sa.save!
      a = Account.find_by_code(ACCOUNT_CODE_LEGAL_WELFARE)
      sa = SubAccount.new( :code => SUB_ACCOUNT_CODE_EMPLOYEES_INSURANCE_OF_LEGAL_WELFARE, :name => '雇用保険料' )
      sa.account = a
      sa.save!
    end
  end
  def self.down
    SubAccount.transaction do
      a = Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY)
      a.sub_accounts.find{|sa|sa.code == SUB_ACCOUNT_CODE_EMPLOYEES_INSURANCE_OF_ADVANCE_MONEY}.delete
      a = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
      a.sub_accounts.find{|sa|sa.code == SUB_ACCOUNT_CODE_EMPLOYEES_INSURANCE_OF_DEPOSITS_RECEIVED}.delete
      a = Account.find_by_code(ACCOUNT_CODE_LEGAL_WELFARE)
      a.sub_accounts.find{|sa|sa.code == SUB_ACCOUNT_CODE_EMPLOYEES_INSURANCE_OF_LEGAL_WELFARE}.delete
    end
  end
end
