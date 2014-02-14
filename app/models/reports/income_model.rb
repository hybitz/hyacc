# -*- encoding : utf-8 -*-
#
# $Id: rent_statement_logic.rb 2278 2010-09-29 12:22:20Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Reports
  class IncomeModel
    attr_accessor :company_name
    attr_accessor :pretax_profit_amount
    attr_accessor :nondiductible_social_expense_amount
    
    def increase_amount
      @nondiductible_social_expense_amount
    end
    
    def decrease_amount
      0
    end
    
    # 仮計
    def provisional_total_amount
      @pretax_profit_amount + increase_amount - decrease_amount
    end
    
    # 合計
    def total_amount
      provisional_total_amount
    end
    
    # 総計
    def grand_total_amount
      total_amount
    end
    
    # 差引計
    def balance_amount
      grand_total_amount
    end
    
    # 所得金額又は欠損金額
    def income_amount
      grand_total_amount
    end
  end
end
