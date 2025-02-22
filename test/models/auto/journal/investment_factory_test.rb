require 'test_helper'

class Auto::Journal::InvestmentFactoryTest < ActiveSupport::TestCase
    
  # 有価証券の購入に手数料がかからない場合のテスト
  def test_make_journals_no_charges
    @investment = Investment.new(yyyymmdd: '2016-03-27', bank_account_id: 3, customer_id: '1',
      buying_or_selling: '1', for_what: '1', shares: '20', trading_value: '100000', charges: '0')
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
end