require 'test_helper'

class Reports::SuspenseReceiptLogicTest < ActiveSupport::TestCase
  def setup
    @account = Account.where(is_suspense_receipt_account: true, sub_account_type: SUB_ACCOUNT_TYPE_CUSTOMER, deleted: false).first
    @fiscal_year = company.fiscal_years.where(closing_status: CLOSING_STATUS_OPEN).order('fiscal_year ASC').second
    @journal1 = Journal.find(35)
    @journal1_jd = @journal1.journal_details.find_by(account_id: @account.id)
    @journal2 = Journal.find(36)
    @journal2_jd = @journal2.journal_details.find_by(account_id: @account.id)
    @journal3 = Journal.find(37)
    @journal3_jd = @journal3.journal_details.find_by(account_id: @account.id)
    @journal4 = Journal.find(38)
    @journal4_jd = @journal4.journal_details.find_by(account_id: @account.id)
  end

  def test_取引先からの仮受金の摘要欄は会計年度内で金額が一番大きい伝票明細のメモを表示する
    @journal4.destroy!
    assert_equal [true, true, 10000, '不明入金1万円'], [@journal1.company == company, @journal1.fiscal_year == @fiscal_year, @journal1_jd.amount, @journal1_jd.note]
    assert_equal [true, true, 20000, '不明入金2万円'], [@journal2.company == company, @journal2.fiscal_year == @fiscal_year, @journal2_jd.amount, @journal2_jd.note]
    assert_equal [false, false, 30000, '不明入金3万円'], [@journal3.company == company, @journal3.fiscal_year == @fiscal_year, @journal3_jd.amount, @journal3_jd.note]
    
    finder = ReportFinder.new(user)
    finder.fiscal_year = @fiscal_year.fiscal_year
    finder.company_id = company.id
    finder.branch_id = 0
    logic = Reports::SuspenseReceiptLogic.new(finder)

    @model = logic.build_model
    assert_equal  ['不明入金2万円　等'], @model.details.map {|d| d.note if d.account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}.compact
 
    @journal3.update!(company_id: company.id)
    assert_equal [true, false], [@journal3.company == company, @journal3.fiscal_year == @fiscal_year]
    @model = logic.build_model
    assert_equal  ['不明入金2万円　等'], @model.details.map {|d| d.note if d.account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}.compact

    @journal3.update!(ym: @fiscal_year.end_year_month + 1)
    assert_equal [true, false], [@journal3.company == company, @journal3.fiscal_year == @fiscal_year]
    @model = logic.build_model
    assert_equal  ['不明入金2万円　等'], @model.details.map {|d| d.note if d.account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}.compact

    @journal3.update!(ym: @fiscal_year.start_year_month)
    assert_equal [true, true], [@journal3.company == company, @journal3.fiscal_year == @fiscal_year]
    @model = logic.build_model
    assert_equal  ['不明入金3万円　等'], @model.details.map {|d| d.note if d.account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}.compact

    JournalDetail.where(account_id: @account.id).map {|jd| jd.update!(note: nil)}
    @model = logic.build_model
    assert_equal  ['誤入金　等'], @model.details.map {|d| d.note if d.account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}.compact
  end

  def test_取引先からの仮受金の摘要欄を部門別に表示する
    assert_equal [true, true, 10000, '不明入金1万円'], [@journal1.company == company, @journal1.fiscal_year == @fiscal_year, @journal1_jd.amount, @journal1_jd.note]
    assert_equal [true, true, 20000, '不明入金2万円'], [@journal2.company == company, @journal2.fiscal_year == @fiscal_year, @journal2_jd.amount, @journal2_jd.note]
    assert_equal [true, true, 100000, '不明入金10万円'], [@journal4.company == company, @journal4.fiscal_year == @fiscal_year, @journal4_jd.amount, @journal4_jd.note]
    assert_equal [1, 1, 2], [@journal1_jd.branch_id, @journal2_jd.branch_id, @journal4_jd.branch_id]

    finder = ReportFinder.new(user)
    finder.fiscal_year = @fiscal_year.fiscal_year
    finder.company_id = company.id
    finder.branch_id = 0
    logic = Reports::SuspenseReceiptLogic.new(finder)
    
    @model1 = logic.build_model
    assert_equal  ['不明入金10万円　等'], @model1.details.map {|d| d.note if d.account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}.compact

    finder = ReportFinder.new(user)
    finder.fiscal_year = @fiscal_year.fiscal_year
    finder.company_id = company.id
    finder.branch_id = 1
    logic = Reports::SuspenseReceiptLogic.new(finder)

    @model = logic.build_model
    assert_equal  ['不明入金2万円　等'], @model.details.map {|d| d.note if d.account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}.compact

    finder = ReportFinder.new(user)
    finder.fiscal_year = @fiscal_year.fiscal_year
    finder.company_id = company.id
    finder.branch_id = 2
    logic = Reports::SuspenseReceiptLogic.new(finder)

    @model = logic.build_model
    assert_equal  ['不明入金10万円　等'], @model.details.map {|d| d.note if d.account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}.compact
  end

end