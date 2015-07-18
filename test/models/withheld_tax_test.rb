require 'test_helper'

class WithheldTaxTest < ActiveSupport::TestCase

  def test_find_by_date_and_salary
    assert wt = WithheldTax.find_by_date_and_salary('2015-08-07', 328000)
    assert_equal 326000, wt.salary_range_from
    assert_equal 329000, wt.salary_range_to
    assert_equal 10630, wt.dependent_0
    assert_equal 7840, wt.dependent_1
    assert_equal 6230, wt.dependent_2
    assert_equal 4610, wt.dependent_3
    assert_equal 2990, wt.dependent_4
    assert_equal 1380, wt.dependent_5
    assert_equal 0, wt.dependent_6
    assert_equal 0, wt.dependent_7
  end

  def test_find_by_date_and_pay_and_dependent
    assert_equal 4610, WithheldTax.find_by_date_and_pay_and_dependent('2015-08-07', 328000, 3)
  end
end
