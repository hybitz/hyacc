module Reports
  class BaseLogic
    include HyaccConstants

    attr_reader :finder, :company, :start_ym, :end_ym

    def initialize(finder)
      @finder = finder
      @company = Company.find(finder.company_id)
      @start_ym = HyaccDateUtil.get_start_year_month_of_fiscal_year(@finder.fiscal_year, @company.start_month_of_fiscal_year)
      @end_ym = HyaccDateUtil.get_end_year_month_of_fiscal_year(@finder.fiscal_year, @company.start_month_of_fiscal_year)
    end
    
    def fiscal_year
      @fiscal_year ||= company.get_fiscal_year(finder.fiscal_year.to_i)
    end
    
    def branch_id
      finder.branch_id.to_i
    end
    
    def branch
      if @branch.nil?
        if branch_id > 0
          @branch = Branch.find(branch_id)
        else
          @branch = false
        end
      end
      
      @branch
    end
    
    def as_company?
      ! as_branch?
    end
    
    def as_branch?
      branch
    end
    
    def start_ymd
      "#{start_ym}01"
    end
    
    def end_ymd
      Date.new(end_ym.to_i / 100, end_ym.to_i % 100, 1).end_of_month.strftime("%Y%m%d")
    end

    # 期首時点での累計金額を取得する
    def get_amount_at_start(account_code, sub_account_id = nil)
      a = Account.where(code: account_code, deleted: false).first
      last_year_end_ym = HyaccDateUtil.get_end_year_month_of_fiscal_year(finder.fiscal_year - 1, finder.start_month_of_fiscal_year )
      VMonthlyLedger.get_net_sum_amount(nil, last_year_end_ym, a.id, sub_account_id, branch_id)
    end
    
    # 期末時点での累計金額を取得する
    def get_amount_at_end(account_code, sub_account_id = nil)
      a = Account.where(code: account_code, deleted: false).first
      VMonthlyLedger.get_net_sum_amount(nil, end_ym, a.id, sub_account_id, branch_id)
    end

    # 当期に増減した金額を取得する
    def get_this_term_amount(account_code, sub_account_id = nil)
      a = Account.where(code: account_code, deleted: false).first
      VMonthlyLedger.get_net_sum_amount(start_ym, end_ym, a.id, sub_account_id, branch_id)
    end

    # 売上総利益を取得する
    def get_gross_profit_amount
      # 売上高
      sale = Account.find_by_code(ACCOUNT_CODE_SALE)
      sale_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, sale.id, 0, branch_id)
      
      # 売上原価
      cost_of_sales = Account.find_by_code(ACCOUNT_CODE_COST_OF_SALES)
      cost_of_sales_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, cost_of_sales.id, 0, branch_id)
      
      sale_amount - cost_of_sales_amount
    end
    
    # 営業利益を取得する
    def get_operating_income_amount
      # 売上総利益
      gross_profit_amount = get_gross_profit_amount
      
      # 販売費および一般管理費
      sales_and_general_administrative_expense = Account.find_by_code(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE)
      sales_and_general_administrative_expense_amount = VMonthlyLedger.get_net_sum_amount(
          @start_ym, @end_ym, sales_and_general_administrative_expense.id, 0, branch_id)
          
      gross_profit_amount - sales_and_general_administrative_expense_amount
    end
    
    # 経常利益を取得する
    def get_ordinary_income_amount
      # 営業利益
      operating_income_amount = get_operating_income_amount
      
      # 営業外収益
      non_operating_profit = Account.find_by_code(ACCOUNT_CODE_NON_OPERATING_PROFIT)
      non_operating_profit_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, non_operating_profit.id, 0, branch_id)

      # 営業外費用
      non_operating_expense = Account.find_by_code(ACCOUNT_CODE_NON_OPERATING_EXPENSE)
      non_operating_expense_amount = VMonthlyLedger.get_net_sum_amount(@start_ym, @end_ym, non_operating_expense.id, 0, branch_id)
      
      operating_income_amount + non_operating_profit_amount - non_operating_expense_amount
    end

    # 税引前当期利益を取得する
    def get_pretax_profit_amount
      profit_account = Account.where('account_type = ? and parent_id is null', ACCOUNT_TYPE_PROFIT).first
      expense_account = Account.where('account_type = ? and parent_id is null', ACCOUNT_TYPE_EXPENSE).first
      profit = VMonthlyLedger.get_net_sum_amount(start_ym, end_ym, profit_account.id, nil, branch_id)
      expense = VMonthlyLedger.get_net_sum_amount(start_ym, end_ym, expense_account.id, nil, branch_id)
      profit - expense
    end
    
    # 法人税を取得する
    def get_corporate_tax_amount
      account = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
      VMonthlyLedger.get_net_sum_amount(start_ym, end_ym, account.id, nil, branch_id)
    end

    # 資本金を取得する
    def get_capital_stock_amount
      capital_stock = Account.find_by_code(ACCOUNT_CODE_CAPITAL_STOCK)
      VMonthlyLedger.get_net_sum_amount(nil, end_ym, capital_stock.id, nil, branch_id)
    end
  end
end
