require 'test_helper'

class EmployeeBankAccountTest < ActiveSupport::TestCase

  def test_金融機関・支店・口座番号が揃っていればエラーにならない
    account = EmployeeBankAccount.new(
      employee: employee,
      bank_id: bank.id,
      bank_office_id: bank.bank_offices.first.id,
      code: '1234567'
    )
    assert account.valid?
  end

  def test_一部でも欠けていればエラーになる
    account = EmployeeBankAccount.new(
      employee: employee,
      bank_id: bank.id,
      bank_office_id: bank.bank_offices.first.id,
      code: ''
    )
    assert account.invalid?
    assert_equal ERR_EMPLOYEE_BANK_ACCOUNT_INCOMPLETE, account.errors[:base].first
  end

end
