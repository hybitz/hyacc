require 'test_helper'

class DeemedTax::DeemedTaxLogicTest < ActiveSupport::TestCase
    
  setup do
    @logic = DeemedTax::DeemedTaxLogic.new
  end

  def test_calc_imposition_base_amount
    assert_equal 0, @logic.calc_imposition_base_amount(0)
    assert_equal 0, @logic.calc_imposition_base_amount(105)
    assert_equal 100000, @logic.calc_imposition_base_amount(105000)
  end
  
  def test_calc_tax_amount
    assert_equal 0, @logic.calc_tax_amount(0, 0.9)
    assert_equal 3, @logic.calc_tax_amount(100, 0.9)
    assert_equal 2, @logic.calc_tax_amount(99, 0.9)
  end
  
  def test_calc_local_tax_amount
    assert_equal 0, @logic.calc_local_tax_amount(0)
    assert_equal 0, @logic.calc_local_tax_amount(3)
    assert_equal 1, @logic.calc_local_tax_amount(4)
  end
  
  def test_calc_total_tax_amount
    assert_equal 0, @logic.calc_total_tax_amount(0, 0)
    assert_equal 1, @logic.calc_total_tax_amount(1, 0)
    assert_equal 1, @logic.calc_total_tax_amount(0, 1)
    assert_equal 10, @logic.calc_total_tax_amount(8, 2)
  end

end
