require 'test_helper'

class Auto::Journal::InvestmentFactoryTest < ActiveSupport::TestCase
    
  # 有価証券の購入に手数料がかからない場合のテスト
  def test_make_journals_no_charges
    @investment = Investment.new(yyyymmdd: '2016-03-27', bank_account_id: 3, customer_id: '1',
      buying_or_selling: '1', for_what: '1', shares: '20', trading_value: '100000', charges: '0') 
    ym = @investment.yyyymmdd.split("-")[0..1].join.to_i
    assert_equal TAX_MANAGEMENT_TYPE_EXCLUSIVE, user.employee.company.get_fiscal_year(ym).tax_management_type
    factory = Auto::Journal::InvestmentFactory.get_instance(Auto::Journal::InvestmentParam.new(@investment, user))
    journals = factory.make_journals

    assert_not_nil journals
    assert_equal 1, journals.size

    jh = journals[0]
    assert_equal SLIP_TYPE_INVESTMENT, jh.slip_type
    assert_equal 2, jh.journal_details.size

    jd = jh.journal_details[0]
    assert_equal Account.find_by_code(ACCOUNT_CODE_TRADING_SECURITIES).id, jd.account_id
    assert_equal 100_000, jd.amount
    
    jd = jh.journal_details[1]
    assert_equal Account.find_by_code(ACCOUNT_CODE_DEPOSITS_PAID).id, jd.account_id
    assert_equal 100_000, jd.amount
  end

  def test_make_journals
    @investment = Investment.new(yyyymmdd: '2016-03-27', bank_account_id: 3, customer_id: '1',
      buying_or_selling: '1', for_what: '1', shares: '20', trading_value: '100000', charges: '1080')
    ym = @investment.yyyymmdd.split("-")[0..1].join.to_i
    assert_equal TAX_MANAGEMENT_TYPE_EXCLUSIVE, user.employee.company.get_fiscal_year(ym).tax_management_type
    factory = Auto::Journal::InvestmentFactory.get_instance(Auto::Journal::InvestmentParam.new(@investment, user))
    journals = factory.make_journals

    assert_not_nil journals
    assert_equal 1, journals.size

    jh = journals[0]
    assert_equal SLIP_TYPE_INVESTMENT, jh.slip_type
    assert_equal 4, jh.journal_details.size

    jd = jh.journal_details[0]
    assert_equal Account.find_by_code(ACCOUNT_CODE_TRADING_SECURITIES).id, jd.account_id
    assert_equal 100_000, jd.amount

    jd = jh.journal_details[1]
    assert_equal Account.find_by_code(ACCOUNT_CODE_TEMP_PAY_TAX).id, jd.account_id
    assert_equal 80, jd.amount

    jd = jh.journal_details[2]
    assert_equal Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id, jd.account_id
    assert_equal 1000, jd.amount

    jd = jh.journal_details[3]
    assert_equal Account.find_by_code(ACCOUNT_CODE_DEPOSITS_PAID).id, jd.account_id
    assert_equal 101_080, jd.amount
  end

  def test_make_journals_消費税が1円未満の場合は仮払消費税の自動仕訳明細を作成しない
    @investment = Investment.new(yyyymmdd: '2016-03-27', bank_account_id: 3, customer_id: '1',
      buying_or_selling: '1', for_what: '1', shares: '20', trading_value: '100000', charges: '10')
    ym = @investment.yyyymmdd.split("-")[0..1].join.to_i
    assert_equal TAX_MANAGEMENT_TYPE_EXCLUSIVE, user.employee.company.get_fiscal_year(ym).tax_management_type
    factory = Auto::Journal::InvestmentFactory.get_instance(Auto::Journal::InvestmentParam.new(@investment, user))
    journals = factory.make_journals

    jh = journals[0]
    assert_equal SLIP_TYPE_INVESTMENT, jh.slip_type
    tax_rate = TaxJp::ConsumptionTax.rate_on(jh.date)
    assert @investment.charges - (@investment.charges / (1 + tax_rate)).ceil < 1
    assert_equal 3, jh.journal_details.size

    jd = jh.journal_details[0]
    assert_equal Account.find_by_code(ACCOUNT_CODE_TRADING_SECURITIES).id, jd.account_id
    assert_equal 100_000, jd.amount

    jd = jh.journal_details[1]
    assert_equal Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id, jd.account_id
    assert_equal 10, jd.amount

    jd = jh.journal_details[2]
    assert_equal Account.find_by_code(ACCOUNT_CODE_DEPOSITS_PAID).id, jd.account_id
    assert_equal 100_010, jd.amount
  end

  def test_make_journals_税込経理方式の場合は仮払消費税の自動仕訳明細を作成しない
    @investment = Investment.new(yyyymmdd: '2016-03-27', bank_account_id: 3, customer_id: '1',
      buying_or_selling: '1', for_what: '1', shares: '20', trading_value: '100000', charges: '1080')
    ym = @investment.yyyymmdd.split("-")[0..1].join.to_i
    assert user.employee.company.get_fiscal_year(ym).update!(tax_management_type: TAX_MANAGEMENT_TYPE_INCLUSIVE)
    factory = Auto::Journal::InvestmentFactory.get_instance(Auto::Journal::InvestmentParam.new(@investment, user))
    journals = factory.make_journals

    assert_not_nil journals
    assert_equal 1, journals.size

    jh = journals[0]
    assert_equal SLIP_TYPE_INVESTMENT, jh.slip_type
    assert_equal 3, jh.journal_details.size

    jd = jh.journal_details[0]
    assert_equal Account.find_by_code(ACCOUNT_CODE_TRADING_SECURITIES).id, jd.account_id
    assert_equal 100_000, jd.amount

    jd = jh.journal_details[1]
    assert_equal Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id, jd.account_id
    assert_equal 1080, jd.amount

    jd = jh.journal_details[2]
    assert_equal Account.find_by_code(ACCOUNT_CODE_DEPOSITS_PAID).id, jd.account_id
    assert_equal 101_080, jd.amount
  end
end