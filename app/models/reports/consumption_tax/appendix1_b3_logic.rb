class Reports::ConsumptionTax::Appendix1B3Logic < Reports::BaseLogic

  def build_model
    ret = HeaderModel.new

    ret.company = Company.find(finder.company_id)
    ret.fiscal_year = fiscal_year
    ret.sale_amount_raw = get_this_term_amount(ACCOUNT_CODE_SALE)
    ret
  end

end

class HeaderModel
  attr_accessor :company
  attr_accessor :fiscal_year
  attr_accessor :sale_amount_raw

  def company_name
    company.name
  end

  def sale_amount
    sale_amount_raw - sale_amount_raw % 1000
  end

  def sale_tax_amount
    sale_amount * 0.078
  end

end
