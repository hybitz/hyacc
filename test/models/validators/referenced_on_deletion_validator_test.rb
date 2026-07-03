require 'test_helper'

class ReferencedOnDeletionValidatorTest < ActiveSupport::TestCase
  def test_DELETION_RULES未定義のモデルではArgumentError
    error = assert_raises(ArgumentError) do
      Validators::ReferencedOnDeletionValidator.new.validate(User.new)
    end
    assert_equal 'ReferencedOnDeletionValidator: DELETION_RULES に User のルールが定義されていません', error.message
  end

  def test_Bank_参照なしで削除できる
    bank = banks(:without_linked_accounts)
    assert_not BankAccount.where(bank_id: bank.id, deleted: false).exists?
    assert_not EmployeeBankAccount.where(bank_id: bank.id).exists?

    bank.deleted = true
    assert bank.valid?
  end

  def test_Bank_参照ありでは削除できない
    bank = banks(:with_linked_accounts)
    assert(
      BankAccount.where(bank_id: bank.id, deleted: false).exists? ||
      EmployeeBankAccount.where(bank_id: bank.id).exists?
    )

    bank.deleted = true
    assert bank.invalid?
    assert_equal ERR_BANK_LINKED, bank.errors[:base].first
  end

  def test_BankOffice_参照なしで削除できる
    office = bank_offices(:without_linked_accounts)
    assert_not BankAccount.where(bank_office_id: office.id, deleted: false).exists?
    assert_not EmployeeBankAccount.where(bank_office_id: office.id).exists?

    office.deleted = true
    assert office.valid?
  end

  def test_BankOffice_参照ありでは削除できない
    office = bank_offices(:with_linked_accounts)
    assert(
      BankAccount.where(bank_office_id: office.id, deleted: false).exists? ||
      EmployeeBankAccount.where(bank_office_id: office.id).exists?
    )

    office.deleted = true
    assert office.invalid?
    assert_equal ERR_BANK_OFFICE_LINKED, office.errors[:base].first
  end

  def test_BankAccount_参照なしで削除できる
    account = BankAccount.find(2)
    assert_not Investment.where(bank_account_id: account.id).exists?

    account.deleted = true
    assert account.valid?
  end

  def test_BankAccount_参照ありでは削除できない
    account = BankAccount.find(3)
    assert Investment.where(bank_account_id: account.id).exists?

    account.deleted = true
    assert account.invalid?
    assert_equal ERR_BANK_ACCOUNT_LINKED, account.errors[:base].first
  end

  def test_DonationRecipient_参照なしで削除できる
    dr = DonationRecipient.find(3)
    assert_not dr.journal_details.exists?

    dr.deleted = true
    assert dr.valid?
  end

  def test_DonationRecipient_参照ありでは削除できない
    dr = DonationRecipient.find(1)
    assert dr.journal_details.exists?

    dr.deleted = true
    assert dr.invalid?
    assert_equal ERR_DONATION_RECIPIENT_LINKED, dr.errors[:base].first
  end
end
