require 'test_helper'

class Reports::SuspenseReceiptLogicTest < ActiveSupport::TestCase
  def setup
    @account = Account.find_by_code(ACCOUNT_CODE_SUSPENSE_RECEIPT)
    @account.update!(sub_account_type: SUB_ACCOUNT_TYPE_CUSTOMER, is_suspense_receipt_account: true)
    @fiscal_year = company.fiscal_years.where(closing_status: CLOSING_STATUS_OPEN).order('fiscal_year ASC').first
    
    SimpleSlip.new(params.merge(amount_increase: 10000)).save!
    @journal1 = Journal.last
    @journal1.journal_details.find_by(account_id: @account.id).update!(note: '不明入金1万円')
    
    SimpleSlip.new(params.merge(amount_increase: 20000)).save!
    @journal2 = Journal.last
    @journal2.journal_details.find_by(account_id: @account.id).update!(note: '不明入金2万円')
    
    SimpleSlip.new(params.merge(company_id: 2, ym: Company.second.fiscal_years.where(closing_status: CLOSING_STATUS_OPEN).last.end_year_month, amount_increase: 300000)).save!
    @journal3 = Journal.last
    @journal3.journal_details.find_by(account_id: @account.id).update!(note: '不明入金3万円')
  end

  def test_取引先からの仮受金の摘要欄は金額が一番大きい伝票明細のメモを表示する 
    finder = ReportFinder.new(user)
    finder.fiscal_year = @fiscal_year.fiscal_year
    finder.company_id = company.id
    logic = Reports::SuspenseReceiptLogic.new(finder)
    
    @model = logic.build_model 
    assert_equal [true, true], [@journal1.company == company, @journal1.ym <= @model.end_ym]
    assert_equal [true, true], [@journal2.company == company, @journal2.ym <= @model.end_ym]
    assert_equal [false, false], [@journal3.company == company, @journal3.ym <= @model.end_ym]
    assert_equal  ['不明入金2万円　等'], @model.details.map {|d| d.note if d.account.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}
 
    @journal3.update!(company_id: company.id)
    @model = logic.build_model
    assert_equal [true, false], [@journal3.company == company, @journal3.ym <= @model.end_ym]
    assert_equal  ['不明入金2万円　等'], @model.details.map {|d| d.note if d.account.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}

    @journal3.update!(ym: @model.end_ym)
    @model = logic.build_model
    assert_equal [true, true], [@journal3.company == company, @journal3.ym <= @model.end_ym]
    assert_equal  ['不明入金3万円　等'], @model.details.map {|d| d.note if d.account.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}

    @journal3.journal_details.find_by(account_id: @account.id).update!(amount: 13000, note: '管理部宛ての不明入金1万3千円')
    @journal3.journal_details.build(detail_no: 3, dc_type: DC_TYPE_CREDIT, account_id: @account.id, branch_id: 2, branch_name: "経理部", sub_account_id: 2, amount: 17000, note: '経理部宛ての不明入金1万7千円').save!
    @model = logic.build_model
    assert_equal  ['不明入金2万円　等'], @model.details.map {|d| d.note if d.account.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}

    JournalDetail.where(account_id: @account.id).map {|jd| jd.update!(note: nil)}
    @model = logic.build_model
    assert_equal  ['誤入金　等'], @model.details.map {|d| d.note if d.account.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER}
  end

  private

  def params
    account = Account.find_by_code(ACCOUNT_CODE_SUSPENSE_RECEIPT)
    my_account = Account.find_by_code(ACCOUNT_CODE_CASH)
    ret = {}
    ret[:ym] = @fiscal_year.end_year_month
    ret[:day] = 1
    ret[:my_account_id] = my_account.id
    ret[:company_id] = company.id
    ret[:create_user_id] = user.id
    ret[:remarks] = '簡易入力テスト'
    ret[:account_id] = account.id
    ret[:sub_account_id] = account.sub_accounts.first.id
    ret[:branch_id] = branch.id
    ret[:tax_type] = TAX_TYPE_NONTAXABLE
    ret
  end

end