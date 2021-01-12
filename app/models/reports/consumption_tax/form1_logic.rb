require 'reports/consumption_tax/base_logic'

module Reports
  module ConsumptionTax

    class Form1Logic < BaseLogic

        def build_model
        ret = Form1Model.new
    
        ret.company = Company.find(finder.company_id)
        ret.fiscal_year = fiscal_year
        ret.sale_amount = get_this_term_amount(ACCOUNT_CODE_SALE)
        ret.reduced_sale_amount = 0
        ret.taxable_purchase_amount = get_taxable_purchase_amount(0.1)
        ret.reduced_taxable_purchase_amount = get_taxable_purchase_amount(0.08)
        ret.interim_tax_amount = get_this_term_interim_amount(ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE, CONSUMPTION_TAX_TYPE_NATIONAL)
        ret.interim_local_tax_amount = get_this_term_interim_amount(ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE, CONSUMPTION_TAX_TYPE_LOCAL)
        ret
      end

    end

    class Form1Model < BaseModel
      attr_accessor :interim_tax_amount, :interim_local_tax_amount

      def tax_payment_amount
        total_tax_amount - interim_tax_amount
      end
    
      def local_tax_payment_amount
        total_local_tax_amount - interim_local_tax_amount
      end
    
      def total_tax_payment_amount
        tax_payment_amount + local_tax_payment_amount
      end

    end

  end
end
