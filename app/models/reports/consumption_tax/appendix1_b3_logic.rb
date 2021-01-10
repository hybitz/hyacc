module Reports
  module ConsumptionTax
    class Appendix1B3Logic < Reports::ConsumptionTax::BaseLogic

      def build_model
        ret = Appendix1B3Model.new
    
        ret.company = Company.find(finder.company_id)
        ret.fiscal_year = fiscal_year
        ret.sale_amount = get_this_term_amount(ACCOUNT_CODE_SALE)
        ret.taxable_purchase_amount = get_taxable_purchase_amount(0.1)
        ret.reduced_taxable_purchase_amount = get_taxable_purchase_amount(0.08)
        ret
      end

    end

    class Appendix1B3Model
      attr_accessor :company, :fiscal_year
      attr_accessor :sale_amount
      attr_accessor :taxable_purchase_amount, :reduced_taxable_purchase_amount
    
      def company_name
        company.name
      end
    
      def standard_sale_amount
        sale_amount - sale_amount % 1000
      end
    
      def sale_tax_amount
        standard_sale_amount * 0.078
      end
    
      def taxable_purchase_tax_amount
        (taxable_purchase_amount * 0.078).to_i
      end

      def reduced_taxable_purchase_tax_amount
        (reduced_taxable_purchase_amount * 0.0624).to_i
      end

      def total_taxable_purchase_tax_amount
        taxable_purchase_tax_amount + reduced_taxable_purchase_tax_amount
      end

      def total_tax_amount
        sale_tax_amount - total_taxable_purchase_tax_amount
      end
    
      def total_local_tax_amount
        local_tax_amount = (total_tax_amount * 22 / 78).to_i
        local_tax_amount - local_tax_amount / 100
      end
    end

  end
end
