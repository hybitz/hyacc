module Reports
  # TODO TaxJp から消費税率を取得する
  module ConsumptionTax
    class Appendix2B3Logic < Reports::BaseLogic
    
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

      private

      def get_taxable_purchase_amount(tax_rate)
        query = <<EOF
          select jd.dc_type as dc_type, sum(jd.amount) as amount from journal_details jd
          inner join journals j on (j.id = jd.journal_id)
          inner join accounts a on (a.id = jd.account_id)
          where j.ym >= ? and j.ym <= ?
            and a.account_type = ?
            and jd.tax_rate = ?
          group by jd.dc_type
EOF
        result = execute_query(query, fiscal_year.start_year_month, fiscal_year.end_year_month, ACCOUNT_TYPE_EXPENSE, tax_rate)
        
        ret = 0
        result.each do |hash|
          if hash['dc_type'] == DC_TYPE_DEBIT
            ret += hash['amount']
          else
            ret -= hash['amount']
          end
        end

        ret * 1.1
      end

    end
    
    class Appendix2B3Model
      include HyaccConstants

      attr_accessor :company, :fiscal_year
      attr_accessor :taxable_purchase_amount, :reduced_taxable_purchase_amount
      attr_accessor :sale_amount, :reduced_sale_amount
    
      def company_name
        company.name
      end

      def taxable_purchase_tax_amount
        (taxable_purchase_amount * 0.078).to_i
      end

      def taxable_purchase_amount_with_tax
        taxable_purchase_amount + taxable_purchase_tax_amount
      end

      def reduced_taxable_purchase_tax_amount
        (reduced_taxable_purchase_amount * 0.0624).to_i
      end

      def reduced_taxable_purchase_amount_with_tax
        reduced_taxable_purchase_amount + reduced_taxable_purchase_tax_amount
      end

      def total_sale_amount
        sale_amount + reduced_sale_amount
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
