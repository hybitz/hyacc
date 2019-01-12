module Reports
  class BaseLogic
    include HyaccConstants

    attr_reader :finder, :start_ym, :end_ym

    def initialize(finder)
      @finder = finder
      @start_ym = HyaccDateUtil.get_start_year_month_of_fiscal_year(@finder.fiscal_year, @finder.start_month_of_fiscal_year)
      @end_ym = HyaccDateUtil.get_end_year_month_of_fiscal_year(@finder.fiscal_year, @finder.start_month_of_fiscal_year)
    end

    # 期首時点での累計金額を取得する
    def get_amount_at_start(account_id)
      last_year_end_ym = HyaccDateUtil.get_end_year_month_of_fiscal_year( @finder.fiscal_year - 1, @finder.start_month_of_fiscal_year )
      VMonthlyLedger.get_net_sum_amount(nil, last_year_end_ym, account_id, 0, @finder.branch_id)
    end
    
    # 当期に増減した金額を取得する
    def get_this_term_amount(account_id)
      VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, account_id, 0, @finder.branch_id)
    end

    # 売上総利益を取得する
    def get_gross_profit_amount
      # 売上高
      sale = Account.find_by_code(ACCOUNT_CODE_SALE)
      sale_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, sale.id, 0, @finder.branch_id)
      
      # 売上原価
      cost_of_sales = Account.find_by_code(ACCOUNT_CODE_COST_OF_SALES)
      cost_of_sales_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, cost_of_sales.id, 0, @finder.branch_id)
      
      sale_amount - cost_of_sales_amount
    end
    
    # 営業利益を取得する
    def get_operating_income_amount
      # 売上総利益
      gross_profit_amount = get_gross_profit_amount
      
      # 販売費および一般管理費
      sales_and_general_administrative_expense = Account.find_by_code(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE)
      sales_and_general_administrative_expense_amount = VMonthlyLedger.get_net_sum_amount(
          @start_ym, @end_ym, sales_and_general_administrative_expense.id, 0, @finder.branch_id)
          
      gross_profit_amount - sales_and_general_administrative_expense_amount
    end
    
    # 経常利益を取得する
    def get_ordinary_income_amount
      # 営業利益
      operating_income_amount = get_operating_income_amount
      
      # 営業外収益
      non_operating_profit = Account.find_by_code(ACCOUNT_CODE_NON_OPERATING_PROFIT)
      non_operating_profit_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, non_operating_profit.id, 0, @finder.branch_id)

      # 営業外費用
      non_operating_expense = Account.find_by_code(ACCOUNT_CODE_NON_OPERATING_EXPENSE)
      non_operating_expense_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, non_operating_expense.id, 0, @finder.branch_id)
      
      operating_income_amount + non_operating_profit_amount - non_operating_expense_amount
    end
    
    # 税引前当期利益を取得する
    def get_pretax_profit_amount
      # 経常利益
      ordinary_income_amount = get_ordinary_income_amount
      
      # 特別収益
      extraordinary_profit = Account.find_by_code(ACCOUNT_CODE_EXTRAORDINARY_PROFIT)
      extraordinary_profit_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, extraordinary_profit.id, 0, @finder.branch_id)

      # 特別費用
      extraordinary_expense = Account.find_by_code(ACCOUNT_CODE_EXTRAORDINARY_EXPENSE)
      extraordinary_expense_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, extraordinary_expense.id, 0, @finder.branch_id)
      
      ordinary_income_amount + extraordinary_profit_amount - extraordinary_expense_amount
    end
    
    # 資本金を取得する
    def get_capital_stock_amount
      capital_stock = Account.find_by_code( ACCOUNT_CODE_CAPITAL_STOCK )
      VMonthlyLedger.get_net_sum_amount(nil, @end_ym, capital_stock.id, 0, @finder.branch_id)
    end
  end
end
