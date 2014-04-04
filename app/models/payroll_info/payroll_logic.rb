# -*- encoding : utf-8 -*-
module PayrollInfo
  class PayrollLogic
    include HyaccConstants
    
    def initialize(fiscal_year=nil)
      @fiscal_year = fiscal_year
    end
    
    def get_total_base_salary
      return 100000000000000
    end
  end
end
