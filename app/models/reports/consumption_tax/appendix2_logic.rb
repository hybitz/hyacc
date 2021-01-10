class Reports::ConsumptionTax::Appendix2Logic < Reports::BaseLogic

  def build_model
    ret = ConsumptionTaxCalcModel.new

    ret.company = Company.find(finder.company_id)
    ret.fiscal_year = fiscal_year
    ret.sale_amount = get_this_term_amount(ACCOUNT_CODE_SALE)
    ret.temp_pay_tax_amount = get_this_term_debit_amount(ACCOUNT_CODE_TEMP_PAY_TAX)
    ret.consumption_tax_payable_amount = 0 # TODO 中間申告した消費税額
    
    ret
  end

end

class ConsumptionTaxCalcModel
  attr_accessor :company
  attr_accessor :fiscal_year
  attr_accessor :sale_amount
  attr_accessor :temp_pay_tax_amount
  attr_accessor :consumption_tax_payable_amount

  def company_name
    company.name
  end
  
  def total_sale_amount
    sale_amount
  end
  
  def expense_amount
    (temp_pay_tax_amount - consumption_tax_payable_amount) * 1.08 / 0.08
  end
  
end
