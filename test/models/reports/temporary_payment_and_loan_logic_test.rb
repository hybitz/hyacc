require 'test_helper'

class Reports::TemporaryPaymentAndLoanLogicTest < ActiveSupport::TestCase
  def setup
    year = 2026
    fiscal_year = company.fiscal_years.find_by(fiscal_year: year)
    journals = Journal.where(company_id: company.id, ym: fiscal_year.year_month_range)
    @journals_ids = journals.pluck(:id)

    finder = ReportFinder.new(user)
    finder.fiscal_year = year
    finder.company_id = company.id
    finder.branch_id = branch.id
    @logic = Reports::TemporaryPaymentAndLoanLogic.new(finder)
  end

  def test_仮払金の内訳書を表示する
    temporary_payment_account_codes = Account.where(is_temporary_payment_account: true).pluck(:code)
    expected_codes = [
      ACCOUNT_CODE_TEMPORARY_PAYMENT,
      ACCOUNT_CODE_TEMPORARY_PAYMENT_EMPLOYEE,
      ACCOUNT_CODE_TEMPORARY_PAYMENT_CUSTOMER
    ]
    assert_equal expected_codes.sort, temporary_payment_account_codes.sort

    accounts = Account.where(code: expected_codes).index_by(&:code)
    tp  = accounts[ACCOUNT_CODE_TEMPORARY_PAYMENT]
    tpe = accounts[ACCOUNT_CODE_TEMPORARY_PAYMENT_EMPLOYEE]
    tpc = accounts[ACCOUNT_CODE_TEMPORARY_PAYMENT_CUSTOMER]

    tp_details = JournalDetail.where(journal_id: @journals_ids, account_id: tp.id, branch_id: branch.id).to_a
    tpe_details_grouped = JournalDetail.where(journal_id: @journals_ids, account_id: tpe.id, branch_id: branch.id).group_by(&:sub_account_id)
    tpc_details_grouped = JournalDetail.where(journal_id: @journals_ids, account_id: tpc.id, branch_id: branch.id).group_by(&:sub_account_id)

    model = @logic.build_model
    expected_count = (tp_details.any? ? 1 : 0) + tpe_details_grouped.size + tpc_details_grouped.size
    assert_equal expected_count, model.temporary_payment_details.size

    details_indexed = model.temporary_payment_details.index_by { |d| [d.account.code, d.sub_account&.id] }

    if tp_details.any?
      d = details_indexed[[ACCOUNT_CODE_TEMPORARY_PAYMENT, nil]]
      assert_not_nil d
      largest_detail = tp_details.max_by(&:amount)
      note = largest_detail.note
      sum = tp_details.sum(&:amount)
      assert_equal '仮払金', d.account_name
      assert_nil d.counterpart_name
      assert_nil d.counterpart_address
      assert_equal sum, d.amount_at_end
      if note.blank?
        assert_equal "誤出金　等", d.note
      else
        assert_equal "#{note}　等", d.note
      end
    end

    tpe_details_grouped.each do |sub_account_id, details|
      d = details_indexed[[ACCOUNT_CODE_TEMPORARY_PAYMENT_EMPLOYEE, sub_account_id]]
      assert_not_nil d
      sum = details.sum(&:amount)
      assert_equal '仮払金', d.account_name
      assert_nil d.counterpart_name
      assert_nil d.counterpart_address
      assert_equal sum, d.amount_at_end
      assert_equal "#{d.sub_account.name}の#{d.account.name}", d.note
    end

    tpc_details_grouped.each do |sub_account_id, details|
      d = details_indexed[[ACCOUNT_CODE_TEMPORARY_PAYMENT_CUSTOMER, sub_account_id]]
      assert_not_nil d
      largest_detail = details.max_by(&:amount)
      note = largest_detail.note
      sum = details.sum(&:amount)
      customer = Customer.find(sub_account_id)
      assert_equal '仮払金', d.account_name
      assert_equal customer.formal_name, d.counterpart_name
      assert_equal customer.address, d.counterpart_address
      assert_equal sum, d.amount_at_end
      if note.blank?
        assert_equal "誤出金　等", d.note
      else
        assert_equal "#{note}　等", d.note
      end
    end
  end

  def test_仮払金科目を追加して内訳書に表示する
    a = Account.find_by_code(ACCOUNT_CODE_PREPAID_EXPENSE)
    a.update!(is_temporary_payment_account: true)

    model = @logic.build_model
    d = model.temporary_payment_details.find { |d| d.account.code == ACCOUNT_CODE_PREPAID_EXPENSE }
    details = JournalDetail.where(journal_id: @journals_ids, account_id: a.id, branch_id: branch.id).to_a
    sum = details.sum(&:amount)
    largest_detail = details.max_by(&:amount)

    assert_equal '仮払金', d.account_name
    assert_nil d.counterpart_name
    assert_nil d.counterpart_address
    assert_equal sum, d.amount_at_end
    assert_equal a.name, d.note
    assert_nil largest_detail.note
  end

  def test_貸付金の内訳書を表示する
    employee = Employee.find(10)
    customer = Customer.find(4)

    model = @logic.build_model

    employee_detail = model.loan_details.find do |d|
      d.sub_account_type == SUB_ACCOUNT_TYPE_EMPLOYEE && d.sub_account.id == employee.id
    end
    assert_not_nil employee_detail
    assert_equal 500_000, employee_detail.amount_at_end
    assert_equal 5_000, employee_detail.interest_in_period
    assert_equal employee.fullname, employee_detail.counterpart_name
    assert_equal "役員・代表者との関係：#{employee.relationship_to_representative}", employee_detail.counterpart_relation

    customer_detail = model.loan_details.find do |d|
      d.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER && d.sub_account.id == customer.id
    end
    assert_not_nil customer_detail
    assert_equal 100_000, customer_detail.amount_at_end
    assert_equal 3_000, customer_detail.interest_in_period
    assert_equal customer.formal_name, customer_detail.counterpart_name
    assert_equal customer.address, customer_detail.counterpart_address
    assert_equal customer.enterprise_number, customer_detail.registration_number
    assert_equal '株主', customer_detail.counterpart_relation

    parent_details = model.loan_details.select(&:parent_only?)
    assert_equal 1, parent_details.size
    parent_detail = parent_details.first
    assert_equal 80_000, parent_detail.amount_at_end
    assert_nil parent_detail.counterpart_name
    assert_nil parent_detail.counterpart_address
    assert_nil parent_detail.counterpart_relation

    employee2 = Employee.find(2)
    employee2_detail = model.loan_details.find do |d|
      d.sub_account_type == SUB_ACCOUNT_TYPE_EMPLOYEE && d.sub_account.id == employee2.id
    end
    assert_not_nil employee2_detail
    assert_equal 0, employee2_detail.amount_at_end
    assert_equal 1_000, employee2_detail.interest_in_period
    assert_nil employee2_detail.counterpart_relation

    assert_operator model.loan_details.size, :>=, 7
    assert_equal 680_000, model.loan_total_amount_at_end
    assert_equal 9_000, model.loan_total_interest_in_period
  end

  def test_貸付金は借方と貸方を相殺した残高を表示する
    year = 2025
    fiscal_year = company.fiscal_years.find_by(fiscal_year: year)
    journals_ids = Journal.where(company_id: company.id, ym: fiscal_year.year_month_range).pluck(:id)

    finder = ReportFinder.new(user)
    finder.fiscal_year = year
    finder.company_id = company.id
    finder.branch_id = branch.id
    logic = Reports::TemporaryPaymentAndLoanLogic.new(finder)

    employee = Employee.find(2)
    short_term_loan_employee = Account.find_by_code(ACCOUNT_CODE_SHORT_TERM_LOAN_EMPLOYEE)

    details = JournalDetail.where(
      journal_id: journals_ids, account_id: short_term_loan_employee.id, branch_id: branch.id, sub_account_id: employee.id
    )
    debit_sum = details.where(dc_type: DC_TYPE_DEBIT).sum(:amount)
    credit_sum = details.where(dc_type: DC_TYPE_CREDIT).sum(:amount)

    model = logic.build_model
    employee_detail = model.loan_details.find do |d|
      d.sub_account_type == SUB_ACCOUNT_TYPE_EMPLOYEE && d.sub_account.id == employee.id
    end

    assert_equal 300_000, debit_sum
    assert_equal 50_000, credit_sum
    assert_equal debit_sum - credit_sum, employee_detail.amount_at_end
  end
end