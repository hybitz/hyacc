module Reports
  class SurplusReserveAndCapitalStockLogic < BaseLogic
    include JournalUtil

    def initialize(finder)
      super(finder)
    end
    
    def get_surplus_reserve_and_capital_stock
      ret = SurplusReserveAndCapitalStockModel.new
      
      accounts = Account.where(:is_revenue_reserve_account => true)
      accounts.each_with_index do |a, index|
        sr = SurplusReserveModel.new
        sr.no = index + 1
        sr.name = a.name
        sr.amount_at_start = get_amount_at_start(a.id)
        
        this_term_amount = get_this_term_amount(a.id)
        if this_term_amount >= 0
          sr.amount_increase = this_term_amount
        else
          sr.amount_decrease = this_term_amount * -1
        end

        ret.surplus_reserves << sr
      end
      (22 - accounts.count).times do |i|
        sr = SurplusReserveModel.new
        sr.no = accounts.size + i + 1
        ret.surplus_reserves << sr
      end
      
      # 繰越損益金
      pretax_profit_amount = get_pretax_profit_amount
      if pretax_profit_amount >= 0
        ret.profit_carried_forward = pretax_profit_amount
      else
        ret.loss_carried_forward = pretax_profit_amount * -1
      end

      ret
    end
  end
end
