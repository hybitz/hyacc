require 'test_helper'

class ReferencedOnDisableValidatorTest < ActiveSupport::TestCase
  def test_DISABLE_RULES未定義のモデルではArgumentError
    error = assert_raises(ArgumentError) do
      Validators::ReferencedOnDisableValidator.new.validate(User.new)
    end
    assert_equal 'ReferencedOnDisableValidator: DISABLE_RULES に User のルールが定義されていません', error.message
  end

  def test_Bank_参照なしで無効化できる
    bank = banks(:without_linked_accounts)
    assert_not BankAccount.where(bank_id: bank.id, deleted: false).exists?
    assert_not EmployeeBankAccount.where(bank_id: bank.id).exists?

    bank.disabled = true
    assert bank.valid?
  end

  def test_Bank_参照ありでは無効化できない
    bank = banks(:with_linked_accounts)
    assert(
      BankAccount.where(bank_id: bank.id, deleted: false).exists? ||
      EmployeeBankAccount.where(bank_id: bank.id).exists?
    )

    bank.disabled = true
    assert bank.invalid?
    assert_equal ERR_BANK_DISABLE_LINKED, bank.errors[:base].first
  end

  def test_BankOffice_参照なしで無効化できる
    office = bank_offices(:without_linked_accounts)
    assert_not BankAccount.where(bank_office_id: office.id, deleted: false).exists?
    assert_not EmployeeBankAccount.where(bank_office_id: office.id).exists?

    office.disabled = true
    assert office.valid?
  end

  def test_BankOffice_参照ありでは無効化できない
    office = bank_offices(:with_linked_accounts)
    assert(
      BankAccount.where(bank_office_id: office.id, deleted: false).exists? ||
      EmployeeBankAccount.where(bank_office_id: office.id).exists?
    )

    office.disabled = true
    assert office.invalid?
    assert_equal ERR_BANK_OFFICE_DISABLE_LINKED, office.errors[:base].first
  end
end
