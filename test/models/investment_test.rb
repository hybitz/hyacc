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

end
