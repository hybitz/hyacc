require 'test_helper'

class WithheldTaxTest < ActiveSupport::TestCase

  def test_find_by_date_and_salary_and_dependent
    assert_equal 53_980, WithheldTax.find_by_date_and_salary_and_dependent('2024-01-01', 740_000, 3)
    
    extra_rate = TaxJp::WithheldTax.find_by_date_and_salary('2024-01-01', 750_000).extra_rate
    amount = 53_980 + ((750_000 - 740_000)*extra_rate).to_i
    assert_equal amount, WithheldTax.find_by_date_and_salary_and_dependent('2024-01-01', 750_000, 3)
  end  
end
