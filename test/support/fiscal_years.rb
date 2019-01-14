module FiscalYears
  include HyaccConstants

  def valid_fiscal_year_params(options = {})
    {
      fiscal_year: options[:user].employee.company.current_fiscal_year.fiscal_year + 1,
      closing_status: CLOSING_STATUS_OPEN,
      tax_management_type: TAX_MANAGEMENT_TYPE_DEEMED
    }
  end
  
  def invalid_fiscal_year_params(options = {})
    {
      closing_status: CLOSING_STATUS_OPEN,
      tax_management_type: TAX_MANAGEMENT_TYPE_DEEMED
    }
  end
end