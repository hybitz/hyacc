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
end