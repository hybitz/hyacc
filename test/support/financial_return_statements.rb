module FinancialReturnStatements
  include HyaccConst

  def rent_finder(current_user = nil)
    current_user ||= user
    {
      fiscal_year: current_user.employee.company.current_fiscal_year_int,
      report_type: REPORT_TYPE_RENT
    }
  end
  
  def appendix_04_finder(current_user = nil)
    current_user ||= user
    {
      fiscal_year: current_user.employee.company.current_fiscal_year_int,
      report_type: REPORT_TYPE_APPENDIX_04
    }
  end
  
  def social_expense_finder(current_user = nil)
    current_user ||= user
    {
      :fiscal_year => current_user.employee.company.current_fiscal_year_int,
      :report_type => REPORT_TYPE_SOCIAL_EXPENSE
    }
  end
  
  def profit_and_capital_finder(current_user = nil)
    current_user ||= user
    {
      :fiscal_year => current_user.employee.company.current_fiscal_year_int,
      :report_type => REPORT_TYPE_SURPLUS_RESERVE_AND_CAPITAL_STOCK
    }
  end
  
  def tax_and_dues_finder(current_user = nil)
    current_user ||= user
    {
      :fiscal_year => current_user.employee.company.current_fiscal_year_int,
      :report_type => REPORT_TYPE_TAX_AND_DUES
    }
  end
  
  def trade_account_payable_finder(current_user = nil)
    current_user ||= user
    {
      :fiscal_year => current_user.employee.company.current_fiscal_year_int,
      :report_type => REPORT_TYPE_TRADE_ACCOUNT_PAYABLE
    }
  end
  

  def investment_finder(current_user = nil)
    current_user ||= user
    {
      :fiscal_year => current_user.employee.company.current_fiscal_year_int,
      :report_type => REPORT_TYPE_INVESTMENT_SECURITIES
    }
  end
end
