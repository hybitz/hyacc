module Reports
  # 利益積立金額及び資本金等の計算に関する明細書
  class Appendix0501Logic < BaseLogic
    
    def initialize(finder)
      super(finder)
    end
    
    def build_model
      model = Appendix0501Model.new
      model.company_name = company.name
      model.fiscal_year = company.get_fiscal_year(finder.fiscal_year)

      d = model.new_detail
      d.no = 1
      d.name = '利益準備金'
      d.amount_at_start = get_amount_at_start(ACCOUNT_CODE_REVENUE_RESERVE)
      amount = get_this_term_amount(ACCOUNT_CODE_REVENUE_RESERVE)
      if amount < 0
        d.amount_decrease = -amount
      else
        d.amount_increase = amount
      end

      d = model.new_detail
      d.no = 2
      d.name = '積立金'
      
      d = model.new_detail
      d.no = 3
      if as_company? and fiscal_year.approved_loss_amount_of_business_tax > 0
        d.name = '未払い事業税'
        d.amount_at_start = fiscal_year.approved_loss_amount_of_business_tax
        d.amount_increase = fiscal_year.approved_loss_amount_of_business_tax * -1
      end

      d = model.new_detail
      d.no = 4
      if as_company? and fiscal_year.accepted_amount_of_excess_depreciation > 0
        d.name = '減価償却認容分'
        d.amount_increase = fiscal_year.accepted_amount_of_excess_depreciation * -1
      end

      blank_row_range.each do |i|
        d = model.new_detail
        d.no = i
      end
      
      # 未収還付法人税等
      d = model.new_detail
      d.no = blank_row_range.last + 1
      d.name = '未収還付法人税'
      d.amount_at_start = get_amount_at_start(ACCOUNT_CODE_INCOME_TAXES_RECEIVABLE, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      d.amount_at_start += get_amount_at_start(ACCOUNT_CODE_INCOME_TAXES_RECEIVABLE, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      d.amount_decrease = get_this_term_credit_amount(ACCOUNT_CODE_INCOME_TAXES_RECEIVABLE, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      d.amount_decrease += get_this_term_credit_amount(ACCOUNT_CODE_INCOME_TAXES_RECEIVABLE, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      d.amount_increase = get_this_term_debit_amount(ACCOUNT_CODE_INCOME_TAXES_RECEIVABLE, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      d.amount_increase += get_this_term_debit_amount(ACCOUNT_CODE_INCOME_TAXES_RECEIVABLE, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)

      # 繰越損益金
      model.carried_forward_profit_amount = carried_forward_profit_amount

      # 未納法人税
      model.corporate_taxes_payable_amount_at_start = get_amount_at_start(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      model.corporate_taxes_payable_amount_at_start += get_amount_at_start(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      model.corporate_taxes_payable_amount_interim = get_this_term_interim_amount(ACCOUNT_CODE_TEMP_PAY_CORPORATE_TAXES, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      model.corporate_taxes_payable_amount_interim += get_this_term_interim_amount(ACCOUNT_CODE_TEMP_PAY_CORPORATE_TAXES, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      model.corporate_taxes_payable_amount_decrease = get_this_term_debit_amount(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      model.corporate_taxes_payable_amount_decrease += get_this_term_debit_amount(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      model.corporate_taxes_payable_amount_increase = get_this_term_credit_amount(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      model.corporate_taxes_payable_amount_increase += get_this_term_credit_amount(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)

      # 未納道府県民税
      model.perfectual_tax_payable_amount_at_start = get_amount_at_start(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_PREFECTURAL_TAX)
      model.perfectual_tax_payable_amount_interim = get_this_term_interim_amount(ACCOUNT_CODE_TEMP_PAY_CORPORATE_TAXES, CORPORATE_TAX_TYPE_PREFECTURAL_TAX)
      model.perfectual_tax_payable_amount_decrease = get_this_term_debit_amount(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_PREFECTURAL_TAX)
      model.perfectual_tax_payable_amount_increase = get_this_term_credit_amount(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_PREFECTURAL_TAX)

      # 未納市町村民税
      model.municipal_tax_payable_amount = get_amount_at_end(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE, CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX)

      d = model.new_capital_stock_detail
      d.no = 32
      d.name = '資本金又は出資金'
      d.amount_at_start = get_amount_at_start(ACCOUNT_CODE_CAPITAL_STOCK)
      d.amount_increase = get_this_term_amount(ACCOUNT_CODE_CAPITAL_STOCK)
      
      d = model.new_capital_stock_detail
      d.no = 33
      d.name = '資本準備金'

      34.upto(35).each do |i|
        d = model.new_capital_stock_detail
        d.no = i
      end

      model
    end

    private
    
    def blank_row_range
      case start_ym
      when 0..202104
        5.upto(22).to_a
      else
        5.upto(21).to_a
      end
    end
  end

  class Appendix0501Model
    attr_accessor :company_name, :fiscal_year
    attr_accessor :surplus_reserves
    attr_accessor :carried_forward_profit_amount
    attr_accessor :corporate_taxes_payable_amount_at_start, :corporate_taxes_payable_amount_interim, :corporate_taxes_payable_amount_decrease, :corporate_taxes_payable_amount_increase
    attr_accessor :perfectual_tax_payable_amount_at_start, :perfectual_tax_payable_amount_interim, :perfectual_tax_payable_amount_decrease, :perfectual_tax_payable_amount_increase
    attr_accessor :municipal_tax_payable_amount
    attr_accessor :capital_stocks
    
    def initialize
      @surplus_reserves = []
      @income_taxes_receivable_amount = 0
      @capital_stocks = []
    end
  
    def corporate_taxes_payable_amount
      corporate_taxes_payable_amount_at_start - corporate_taxes_payable_amount_decrease + corporate_taxes_payable_amount_increase
    end
  
    def corporate_taxes_payable_amount_at_end
      corporate_taxes_payable_amount + corporate_taxes_payable_amount_interim
    end

    def perfectual_tax_payable_amount
      perfectual_tax_payable_amount_at_start - perfectual_tax_payable_amount_decrease + perfectual_tax_payable_amount_increase
    end

    def perfectual_tax_payable_amount_at_end
      perfectual_tax_payable_amount + perfectual_tax_payable_amount_interim
    end
  
    def new_detail
      ret = Appendix0501DetailModel.new
      @surplus_reserves << ret
      ret
    end
    
    def new_capital_stock_detail
      ret = Appendix0501DetailModel.new
      @capital_stocks << ret
      ret
    end

    def total_amount_at_start
      ret = surplus_reserves.inject(0){|sum, d| sum + d.amount_at_start }
      ret -= corporate_taxes_payable_amount_at_start
      ret -= perfectual_tax_payable_amount_at_start
      ret
    end

    def total_amount_decrease
      ret = surplus_reserves.inject(0){|sum, d| sum + d.amount_decrease }
      ret += corporate_taxes_payable_amount_decrease
      ret += perfectual_tax_payable_amount_decrease
      ret
    end

    def total_amount_increase
      ret = surplus_reserves.inject(0){|sum, d| sum + d.amount_increase }
      ret += carried_forward_profit_amount
      ret -= corporate_taxes_payable_amount_at_end
      ret -= perfectual_tax_payable_amount_at_end
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
  
  class Appendix0501DetailModel
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
