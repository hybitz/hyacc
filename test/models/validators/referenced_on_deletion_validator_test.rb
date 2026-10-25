require 'test_helper'

class ReferencedOnDeletionValidatorTest < ActiveSupport::TestCase
  def test_DELETION_RULES未定義のモデルではArgumentError
    error = assert_raises(ArgumentError) do
      Validators::ReferencedOnDeletionValidator.new.validate(User.new)
    end
    assert_equal 'ReferencedOnDeletionValidator: DELETION_RULES に User のルールが定義されていません', error.message
  end

  def test_Bank_参照なしで削除できる
    bank = Bank.find(2)
    assert_not BankAccount.where(bank_id: bank.id, deleted: false).exists?
    assert_not EmployeeBankAccount.where(bank_id: bank.id).exists?

    bank.deleted = true
    assert bank.valid?
  end

  def test_Bank_参照ありでは削除できない
    bank = Bank.find(1)
    assert(
      BankAccount.where(bank_id: bank.id, deleted: false).exists? ||
      EmployeeBankAccount.where(bank_id: bank.id).exists?
    )

    bank.deleted = true
    assert bank.invalid?
    assert_equal ERR_BANK_LINKED, bank.errors[:base].first
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

  def test_Branch_参照なしで削除できる
    branch = branches(:for_deletion)
    assert_not Branch.where(parent_id: branch.id, deleted: false).exists?
    assert_not JournalDetail.where(branch_id: branch.self_and_descendants.map(&:id)).exists?
    assert_not SimpleSlipTemplate.where(branch_id: branch.self_and_descendants.map(&:id), deleted: false).exists?
    employee = employees(:deleted_employee)
    assert employee.deleted?
    assert BranchEmployee.exists?(branch_id: branch.id, employee_id: employee.id, deleted: false)

    branch.deleted = true
    assert branch.valid?
  end

  def test_Branch_子部門と紐づいているときは削除できない
    parent = Branch.find(2)
    assert Branch.where(parent_id: parent.id, deleted: false).exists?

    parent.deleted = true
    assert parent.invalid?
    assert_equal ERR_BRANCH_LINKED, parent.errors[:base].first
  end

  def test_Branch_仕訳明細と紐づいているときは削除できない
    branch = Branch.find(6)
    assert JournalDetail.where(branch_id: branch.id).exists?

    branch.deleted = true
    assert branch.invalid?
    assert_equal ERR_BRANCH_LINKED, branch.errors[:base].first
  end

  def test_Branch_従業員所属と紐づいているときは削除できない
    branch = Branch.find(7)
    employee = Employee.find(3)
    assert BranchEmployee.exists?(branch_id: branch.id, employee_id: employee.id, deleted: false)
    assert_not employee.deleted?

    branch.deleted = true
    assert branch.invalid?
    assert_equal ERR_BRANCH_LINKED, branch.errors[:base].first
  end

  def test_Branch_削除済み従業員の所属のみのときは削除できる
    branch = branches(:for_deletion)
    employee = employees(:deleted_employee)
    assert BranchEmployee.exists?(branch_id: branch.id, employee_id: employee.id, deleted: false)
    assert employee.deleted?

    branch.deleted = true
    assert branch.valid?
  end

  def test_Branch_簡易入力テンプレートと紐づいているときは削除できない
    branch = branches(:with_simple_slip_template)
    assert SimpleSlipTemplate.exists?(branch_id: branch.id, deleted: false)

    branch.deleted = true
    assert branch.invalid?
    assert_equal ERR_BRANCH_LINKED, branch.errors[:base].first
  end

  def test_Customer_参照なしで削除できる
    customer = customers(:for_deletion)
    assert_not Career.where(customer_id: customer.id).exists?
    assert_not Investment.where(customer_id: customer.id).exists?
    assert_not Rent.where(customer_id: customer.id).exists?

    customer.deleted = true
    assert customer.valid?
  end

  def test_Customer_業務経歴と紐づいているときは削除できない
    customer = Customer.find(2)
    assert Career.where(customer_id: customer.id).exists?

    customer.deleted = true
    assert customer.invalid?
    assert_equal ERR_CUSTOMER_LINKED, customer.errors[:base].first
  end

  def test_Customer_有価証券と紐づいているときは削除できない
    customer = Customer.find(3)
    assert Investment.where(customer_id: customer.id).exists?

    customer.deleted = true
    assert customer.invalid?
    assert_equal ERR_CUSTOMER_LINKED, customer.errors[:base].first
  end

  def test_Customer_地代家賃と紐づいているときは削除できない
    customer = Customer.find(7)
    assert Rent.where(customer_id: customer.id).exists?

    customer.deleted = true
    assert customer.invalid?
    assert_equal ERR_CUSTOMER_LINKED, customer.errors[:base].first
  end

  def test_Employee_参照なしで削除できる
    employee = Employee.find(7)
    assert_not Career.where(employee_id: employee.id).exists?
    assert_not Exemption.where(employee_id: employee.id).exists?
    assert_not InhabitantTax.where(employee_id: employee.id).exists?

    employee.deleted = true
    assert employee.valid?
  end

  def test_Employee_業務経歴と紐づいているときは削除できない
    employee = Employee.find(1)
    assert Career.where(employee_id: employee.id).exists?

    employee.deleted = true
    assert employee.invalid?
    assert_equal ERR_EMPLOYEE_LINKED, employee.errors[:base].first
  end

  def test_Employee_所得税控除と紐づいているときは削除できない
    employee = Employee.find(6)
    assert Exemption.where(employee_id: employee.id).exists?

    employee.deleted = true
    assert employee.invalid?
    assert_equal ERR_EMPLOYEE_LINKED, employee.errors[:base].first
  end

  def test_Employee_住民税と紐づいているときは削除できない
    employee = Employee.find(8)
    assert InhabitantTax.where(employee_id: employee.id).exists?

    employee.deleted = true
    assert employee.invalid?
    assert_equal ERR_EMPLOYEE_LINKED, employee.errors[:base].first
  end
end
