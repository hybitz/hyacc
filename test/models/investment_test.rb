require 'test_helper'

class InvestmentTest < ActiveSupport::TestCase

  def test_set_yyyymmdd
    investment = Investment.first
    assert_equal 201503, investment.ym
    assert_equal 1, investment.day

    assert_equal "2015-03-01", investment.yyyymmdd

    investment = Investment.second
    assert_equal 201603, investment.ym
    assert_equal 10, investment.day

    assert_equal "2016-03-10", investment.yyyymmdd
  end

  def test_yyyymmdd_date_validation_with_valid_date
    investment = Investment.new(
      yyyymmdd: '2024-03-15',
      bank_account_id: 3,
      customer_id: 1,
      buying_or_selling: '1',
      for_what: 1,
      shares: 10,
      trading_value: 50000,
      charges: 500
    )
    investment.valid?
    assert_empty investment.errors[:yyyymmdd]
  end

  def test_yyyymmdd_date_validation_with_invalid_format
    investment = Investment.new(
      yyyymmdd: '2024/03/15',
      bank_account_id: 3,
      customer_id: 1,
      buying_or_selling: '1',
      for_what: 1,
      shares: 10,
      trading_value: 50000,
      charges: 500
    )
    investment.valid?
    assert investment.errors[:yyyymmdd].include?('は YYYY-MM-DD 形式で入力して下さい。')
  end

end
