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
  
  def appendix_15_finder(current_user = nil)
    current_user ||= user
    {
      :fiscal_year => current_user.employee.company.current_fiscal_year_int,
      :report_type => REPORT_TYPE_APPENDIX_15
    }
  end
  
  def appendix_05_01_finder(current_user = nil)
    current_user ||= user
    {
      :fiscal_year => current_user.employee.company.current_fiscal_year_int,
      :report_type => REPORT_TYPE_APPENDIX_05_01
    }
  end
  
  def appendix_05_02_finder(current_user = nil)
    current_user ||= user
    {
      :fiscal_year => current_user.employee.company.current_fiscal_year_int,
      :report_type => REPORT_TYPE_APPENDIX_05_02
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
