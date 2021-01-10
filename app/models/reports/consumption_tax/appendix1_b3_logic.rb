class Reports::ConsumptionTax::Appendix1B3Logic < Reports::BaseLogic

  def build_model
    ret = HeaderModel.new

    ret.company = Company.find(finder.company_id)
    ret.fiscal_year = fiscal_year
    ret
  end

end

class HeaderModel
  attr_accessor :company
  attr_accessor :fiscal_year

  def company_name
    company.name
  end
  
end
