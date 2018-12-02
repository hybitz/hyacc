require 'test_helper'

class WithheldTaxTest < ActiveSupport::TestCase

  def test_find_by_date_and_salary_and_dependent
    assert_equal 4610, WithheldTax.find_by_date_and_salary_and_dependent('2015-08-07', 328000, 3)
  end
end
