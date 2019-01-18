module Reports
  class ProfitAndCapitalLogic < BaseLogic

    def build_model
      ret = ProfitAndCapitalModel.new
      
      accounts = Account.where(is_revenue_reserve_account: true)
      accounts.each_with_index do |a, index|
        sr = ProfitAndCapitalDetailModel.new
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
        sr = ProfitAndCapitalDetailModel.new
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

  class ProfitAndCapitalModel
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
  
  class ProfitAndCapitalDetailModel
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
