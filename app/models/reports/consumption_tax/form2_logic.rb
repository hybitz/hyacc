module Reports
  module ConsumptionTax
    class Form2Logic < BaseLogic

      def build_model
        ret = Form2Model.new
    
        ret.company = Company.find(finder.company_id)
        ret.fiscal_year = fiscal_year
        ret.sale_amount = get_this_term_amount(ACCOUNT_CODE_SALE)
        ret.reduced_sale_amount = 0
        ret.taxable_purchase_amount = get_taxable_purchase_amount(0.1)
        ret.reduced_taxable_purchase_amount = get_taxable_purchase_amount(0.08)
        ret
      end

    end

    class Form2Model < BaseModel
    end

  end
end
