def valid_fiscal_year_params(options = {})
  {
    :company_id => options[:user].company_id,
    :fiscal_year => options[:user].company.current_fiscal_year.fiscal_year + 1,
    :closing_status => CLOSING_STATUS_OPEN,
    :tax_management_type => TAX_MANAGEMENT_TYPE_DEEMED
  }
end
