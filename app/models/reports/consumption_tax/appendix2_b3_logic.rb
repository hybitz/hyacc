module Reports
  # TODO TaxJp から消費税率を取得する
  module ConsumptionTax
    class Appendix2B3Logic < BaseLogic
    
      def build_model
        ret = Appendix2B3Model.new
    
        ret.company = Company.find(finder.company_id)
        ret.fiscal_year = fiscal_year
        ret.sale_amount = get_this_term_amount(ACCOUNT_CODE_SALE)
        ret.reduced_sale_amount = 0
        ret.taxable_purchase_amount = get_taxable_purchase_amount(0.1)
        ret.reduced_taxable_purchase_amount = get_taxable_purchase_amount(0.08)
        ret
      end

    end
    
    class Appendix2B3Model < BaseModel
      attr_accessor :taxable_purchase_amount, :reduced_taxable_purchase_amount

      def taxable_purchase_tax_amount
        (taxable_purchase_amount * 0.078).to_i
      end

      def taxable_purchase_amount_with_tax
        (taxable_purchase_amount + (taxable_purchase_amount * 0.1)).to_i
      end

      def reduced_taxable_purchase_tax_amount
        (reduced_taxable_purchase_amount * 0.0624).to_i
      end

      def reduced_taxable_purchase_amount_with_tax
        (reduced_taxable_purchase_amount + (reduced_taxable_purchase_amount * 0.08)).to_i
      end

      def total_taxable_purchase_amount
        taxable_purchase_amount + reduced_taxable_purchase_amount
      end

      def total_taxable_purchase_tax_amount
        taxable_purchase_tax_amount + reduced_taxable_purchase_tax_amount
      end

      def total_taxable_purchase_amount_with_tax
        taxable_purchase_amount_with_tax + reduced_taxable_purchase_amount_with_tax
      end

      private

    end

  end
end
