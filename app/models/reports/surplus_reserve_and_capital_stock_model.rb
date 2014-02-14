# -*- encoding : utf-8 -*-
#
# $Id: surplus_reserve_and_capital_stock_model.rb 2477 2011-03-23 15:29:30Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Reports
  class SurplusReserveAndCapitalStockModel
    attr_accessor :surplus_reserves
    attr_accessor :capital_stocks
    # 繰越利益
    attr_accessor :profit_carried_forward
    # 繰越損失
    attr_accessor :loss_carried_forward
    
    def initialize
      @surplus_reserves = []
      @capital_stocks = []
      @profit_carried_forward = 0
      @loss_carried_forward = 0
    end
  end
  
  class SurplusReserveModel
    attr_accessor :no
    attr_accessor :name
    attr_accessor :amount_at_start
    attr_accessor :amount_increase
    attr_accessor :amount_decrease
    
    def initialize
      @amount_at_start = 0
      @amount_increase = 0
      @amount_decrease = 0
    end
    
    def amount_at_end
      @amount_at_start + @amount_increase - @amount_decrease
    end
  end
end
