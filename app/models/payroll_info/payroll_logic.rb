# -*- encoding : utf-8 -*-
#
# $Id: payroll_logic.rb 3132 2013-08-16 05:46:04Z hiro $
# Product: hyacc
# Copyright 2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
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
