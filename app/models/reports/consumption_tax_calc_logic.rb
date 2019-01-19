module Reports
  class ConsumptionTaxCalcLogic < BaseLogic

    def build_model
      ret = ConsumptionTaxCalcModel.new

      ret.company = Company.find(finder.company_id)
      ret.fiscal_year = fiscal_year
      
      ret
    end

  end

  class ConsumptionTaxCalcModel
    attr_accessor :company
    attr_accessor :fiscal_year

    def company_name
      company.name
    end
    
  end
end
