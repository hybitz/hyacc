module Reports
  class ProfitAndCapitalLogic < BaseLogic

    def build_model
      ret = ProfitAndCapitalModel.new

      # 利益準備金
      a = Account.where(code: ACCOUNT_CODE_REVENUE_RESERVE, deleted: false).first
      d = ret.new_detail
      d.no = 1
      d.name = a.name
      d.amount_at_start = get_amount_at_start(a.id)
      d.amount = get_this_term_amount(a.id)

      # 積立金
      d = ret.new_detail
      d.no = 2
      d.name = '積立金'
      
      d = ret.new_detail
      d.no = 3
      if fiscal_year.approved_loss_amount_of_business_tax > 0
        d.name = '未払い事業税'
        d.amount_at_start = fiscal_year.approved_loss_amount_of_business_tax
        d.amount = fiscal_year.approved_loss_amount_of_business_tax * -1
      end

      d = ret.new_detail
      d.no = 4
      if fiscal_year.accepted_amount_of_excess_depreciation > 0
        d.name = '減価償却認容分'
        d.amount = fiscal_year.accepted_amount_of_excess_depreciation * -1
      end

      5.upto(22).each do |i|
        d = ret.new_detail
        d.no = i
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
    
    def new_detail
      ret = ProfitAndCapitalDetailModel.new
      @surplus_reserves << ret
      ret
    end
  end
  
  class ProfitAndCapitalDetailModel
    attr_accessor :no
    attr_accessor :name
    attr_accessor :amount_at_start
    attr_accessor :amount
    
    def initialize
      @amount_at_start = 0
      @amount = 0
    end
    
    def has_change?
      @amount_at_start != 0 || @amount != 0
    end
    
    def amount_increase
      @amount > 0 ? @amount : 0
    end
    
    def amount_decrease
      @amount > 0 ? 0 : @amount * -1
    end

    def amount_at_end
      @amount_at_start + @amount
    end
  end
end
