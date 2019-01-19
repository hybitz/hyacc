module Reports
  class ProfitAndCapitalLogic < BaseLogic

    def build_model
      ret = ProfitAndCapitalModel.new

      a = Account.where(code: ACCOUNT_CODE_REVENUE_RESERVE, deleted: false).first
      d = ret.new_detail
      d.no = 1
      d.name = '利益準備金'
      d.amount_at_start = get_amount_at_start(a.id)
      d.amount_increase = get_this_term_amount(a.id)

      d = ret.new_detail
      d.no = 2
      d.name = '積立金'
      
      d = ret.new_detail
      d.no = 3
      if fiscal_year.approved_loss_amount_of_business_tax > 0
        d.name = '未払い事業税'
        d.amount_at_start = fiscal_year.approved_loss_amount_of_business_tax
        d.amount_increase = fiscal_year.approved_loss_amount_of_business_tax * -1
      end

      d = ret.new_detail
      d.no = 4
      if fiscal_year.accepted_amount_of_excess_depreciation > 0
        d.name = '減価償却認容分'
        d.amount_increase = fiscal_year.accepted_amount_of_excess_depreciation * -1
      end

      5.upto(22).each do |i|
        d = ret.new_detail
        d.no = i
      end
      
      # 繰越損益金
      ret.pretax_profit_amount = get_pretax_profit_amount

      # 未納法人税、未納道府県民税、市町村民税
      a = Account.where(code: ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, deleted: false).first
      ret.corporate_taxes_payable_amount = get_amount_at_end(a.id, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      ret.corporate_taxes_payable_amount += get_amount_at_end(a.id, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      ret.perfectual_tax_payable_amount = get_amount_at_end(a.id, CORPORATE_TAX_TYPE_PREFECTURAL_TAX)
      ret.municipal_tax_payable_amount = get_amount_at_end(a.id, CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX)

      a = Account.where(code: ACCOUNT_CODE_CAPITAL_STOCK, deleted: false).first
      d = ret.new_capital_stock_detail
      d.no = 32
      d.name = '資本金又は出資金'
      d.amount_at_start = get_amount_at_start(a.id)
      d.amount_increase = get_this_term_amount(a.id)
      
      d = ret.new_capital_stock_detail
      d.no = 33
      d.name = '資本準備金'

      34.upto(35).each do |i|
        d = ret.new_capital_stock_detail
        d.no = i
      end

      ret
    end
  end

  class ProfitAndCapitalModel
    attr_accessor :surplus_reserves
    attr_accessor :pretax_profit_amount
    attr_accessor :corporate_taxes_payable_amount
    attr_accessor :perfectual_tax_payable_amount
    attr_accessor :municipal_tax_payable_amount
    attr_accessor :capital_stocks
    
    def initialize
      @surplus_reserves = []
      @pretax_profit_amount = 0
      @corporate_taxes_payable_amount = 0
      @capital_stocks = []
    end
    
    def new_detail
      ret = ProfitAndCapitalDetailModel.new
      @surplus_reserves << ret
      ret
    end
    
    def new_capital_stock_detail
      ret = ProfitAndCapitalDetailModel.new
      @capital_stocks << ret
      ret
    end

    # 繰越利益
    def profit_carried_forward
      @pretax_profit_amount > 0 ? @pretax_profit_amount : 0
    end

    # 繰越損失
    def loss_carried_forward
      @pretax_profit_amount > 0 ? 0 : @pretax_profit_amount * -1
    end
    
    def total_amount_at_start
      surplus_reserves.inject(0){|sum, d| sum + d.amount_at_start }
    end

    def total_amount_decrease
      surplus_reserves.inject(0){|sum, d| sum + d.amount_decrease }
    end

    def total_amount_increase
      ret = surplus_reserves.inject(0){|sum, d| sum + d.amount_increase }
      ret += pretax_profit_amount
      ret -= corporate_taxes_payable_amount
      ret -= perfectual_tax_payable_amount
      ret -= municipal_tax_payable_amount
      ret
    end

    def total_amount_at_end
      total_amount_at_start - total_amount_decrease + total_amount_increase
    end

    def total_capital_amount_at_start
      capital_stocks.inject(0){|sum, d| sum + d.amount_at_start }
    end

    def total_capital_amount_decrease
      capital_stocks.inject(0){|sum, d| sum + d.amount_decrease }
    end

    def total_capital_amount_increase
      capital_stocks.inject(0){|sum, d| sum + d.amount_increase }
    end

    def total_capital_amount_at_end
      total_capital_amount_at_start - total_capital_amount_decrease + total_capital_amount_increase
    end
  end
  
  class ProfitAndCapitalDetailModel
    attr_accessor :no
    attr_accessor :name
    attr_accessor :amount_at_start
    attr_accessor :amount_decrease
    attr_accessor :amount_increase
    
    def initialize
      @amount_at_start = 0
      @amount_decrease = 0
      @amount_increase = 0
    end
    
    def has_change?
      @amount_at_start != 0 || @amount_decrease != 0 || @amount_increase != 0
    end
    
    def amount_at_end
      @amount_at_start - @amount_decrease + @amount_increase
    end
  end
end
