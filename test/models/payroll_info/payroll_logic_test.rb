require 'test_helper'

module PayrollInfo
  class PayrollLogicTest < ActiveSupport::TestCase

    setup do
      finder = PayrollFinder.new(users(:first))
      finder.calendar_year = 2008
      finder.employee_id = users(:first).employee_id
      @logic = PayrollInfo::PayrollLogic.new(finder)
    end
  
    def test_get_total_base_salary
      assert_equal 2653000, @logic.get_total_base_salary
    end
    
    def test_get_deduction
      assert_equal 975600, @logic.get_deduction
    end
    
    def test_get_after_deduction
      # みなし給与のため給与を4000で除して端数を削除後に4000を掛ける
      assert_equal 2652000 - 975600, @logic.get_after_deduction
    end
    
    def test_get_exemption
      assert_equal 1074955, @logic.get_exemption
    end
    
    def test_get_withholding_tax
      # (2652000 - 975600 - 1074955)/1000 * 1000 * 0.05 /100 *100
      assert_equal 30000, @logic.get_withholding_tax
    end
  end
end
