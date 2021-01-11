module Reports
  module ConsumptionTax
    class Reports::ConsumptionTax::Appendix2Logic < BaseLogic

      def build_model
        ret = Appendix12Model.new

        ret.company = Company.find(finder.company_id)
        ret.fiscal_year = fiscal_year
        ret.sale_amount = get_this_term_amount(ACCOUNT_CODE_SALE)
        ret.temp_pay_tax_amount = get_this_term_debit_amount(ACCOUNT_CODE_TEMP_PAY_TAX)
        ret.interim_tax_amount = 0 # TODO 中間申告した消費税額
        
        ret
      end
    
    end
    
    class Appendix12Model < BaseModel
      attr_accessor :sale_amount
      attr_accessor :temp_pay_tax_amount
      attr_accessor :interim_tax_amount
    
      def total_sale_amount
        sale_amount
      end
      
      def expense_amount
        (temp_pay_tax_amount - interim_tax_amount) * 1.08 / 0.08
      end
      
    end

  end
end
