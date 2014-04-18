# -*- encoding : utf-8 -*-
require 'test_helper'

module PayrollInfo
  class PayrollLogicTest <   ActiveSupport::TestCase
  include HyaccConstants
    def setup
      finder = PayrollFinder.new(users(:first))
      finder.calendar_year = "2008"
      finder.employee_id = users(:first).employee_id
      @logic = PayrollInfo::PayrollLogic.new(finder)
    end
  
    def test_get_total_base_salary
      assert_equal 2653000, @logic.get_total_base_salary
    end
    
  end
end
