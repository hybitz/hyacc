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

    tp_details = JournalDetail.where(journal_id: @journals_ids, account_id: tp.id, branch_id: branch.id)
    tpe_details_grouped = JournalDetail.where(journal_id: @journals_ids, account_id: tpe.id, branch_id: branch.id).group_by(&:sub_account_id)
    tpc_details_grouped = JournalDetail.where(journal_id: @journals_ids, account_id: tpc.id, branch_id: branch.id).group_by(&:sub_account_id)

    model = @logic.build_model
    n = (tp_details.present? ? 1 : 0) + tpe_details_grouped.size + tpc_details_grouped.size
    assert_equal n, model.temporary_payment_details.size

    d  = model.temporary_payment_details[0]
    d1 = model.temporary_payment_details[1]
    d2 = model.temporary_payment_details[2]
    d3 = model.temporary_payment_details[3]
    d4 = model.temporary_payment_details[4]

    note = tp_details.order(amount: :desc).first.note
    sum = tp_details.sum(:amount)
    assert_equal '仮払金', d.account_name
    assert_nil d.counterpart_name
    assert_nil d.counterpart_address
    assert_equal sum, d.amount_at_end
    assert_equal "#{note}　等", d.note

    tpe_details1, tpe_details2 = tpe_details_grouped.values
    sum = tpe_details1.sum(&:amount)
    assert_equal '仮払金', d1.account_name
    assert_nil d1.counterpart_name
    assert_nil d1.counterpart_address
    assert_equal sum, d1.amount_at_end
    assert_equal "#{d1.sub_account.name}の#{d1.account.name}", d1.note

    sum = tpe_details2.sum(&:amount)
    assert_equal '仮払金', d2.account_name
    assert_nil d2.counterpart_name
    assert_nil d2.counterpart_address
    assert_equal sum, d2.amount_at_end
    assert_equal "#{d2.sub_account.name}の#{d2.account.name}", d2.note

    tpc_details1, tpc_details2 = tpc_details_grouped.values
    largest_tpc_detail1 = tpc_details1.sort_by { |d| -d.amount }.first
    sum = tpc_details1.sum(&:amount)
    customer = Customer.find(largest_tpc_detail1.sub_account_id)
    assert_equal '仮払金', d3.account_name
    assert_equal customer.formal_name, d3.counterpart_name
    assert_equal customer.address, d3.counterpart_address
    assert_equal sum, d3.amount_at_end
    assert_equal "誤出金　等", d3.note
    assert_nil largest_tpc_detail1.note

    sum = tpc_details2.sum(&:amount)
    largest_tpc_detail2 = tpc_details2.sort_by { |d| -d.amount }.first
    customer = Customer.find(largest_tpc_detail2.sub_account_id)
    assert_equal '仮払金', d4.account_name
    assert_equal customer.formal_name, d4.counterpart_name
    assert_equal customer.address, d4.counterpart_address
    assert_equal sum, d4.amount_at_end
    assert_equal "#{largest_tpc_detail2.note}　等", d4.note
  end

  def test_仮払金科目を追加して内訳書に表示する
    a = Account.find_by_code(ACCOUNT_CODE_PREPAID_EXPENSE)
    a.update!(is_temporary_payment_account: true)

    model = @logic.build_model
    assert_equal 6, model.temporary_payment_details.size
    d = model.temporary_payment_details.find{|d| d.account.code == ACCOUNT_CODE_PREPAID_EXPENSE}
    details = JournalDetail.where(journal_id: @journals_ids, account_id: a.id, branch_id: branch.id)
    sum = details.sum(:amount)
    largest_detail = details.order(amount: :desc).first

    assert_equal '仮払金', d.account_name
    assert_nil d.counterpart_name
    assert_nil d.counterpart_address
    assert_equal sum, d.amount_at_end
    assert_equal a.name, d.note
    assert_nil largest_detail.note
  end
end