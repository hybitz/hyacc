module FinancialStatements
  include HyaccConst

  def bs_monthly_finder
    {
      :fiscal_year => 2007,
      :report_type => REPORT_TYPE_BS,
      :report_style => REPORT_STYLE_MONTHLY
    }
  end
  
  def bs_yearly_finder
    {
      :fiscal_year => 2007,
      :report_type => REPORT_TYPE_BS,
      :report_style => REPORT_STYLE_YEARLY
    }
  end
  
  def pl_monthly_finder
    {
      :fiscal_year => 2007,
      :report_type => REPORT_TYPE_PL,
      :report_style => REPORT_STYLE_MONTHLY
    }
  end
  
  def pl_yearly_finder
    {
      :fiscal_year => 2007,
      :report_type => REPORT_TYPE_PL,
      :report_style => REPORT_STYLE_YEARLY
    }
  end
end