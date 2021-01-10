module Reports
  module ConsumptionTax
    class Appendix2B3Logic < Reports::BaseLogic
    
      def build_model
        ret = Appendix2B3Model.new
    
        ret.company = Company.find(finder.company_id)
        ret.fiscal_year = fiscal_year
        ret.sale_amount_raw = get_this_term_amount(ACCOUNT_CODE_SALE)
        ret
      end
    
    end
    
    # TODO TaxJp から消費税率を取得する
    class Appendix2B3Model
      include HyaccConstants

      attr_accessor :company
      attr_accessor :fiscal_year
      attr_accessor :sale_amount_raw
    
      def company_name
        company.name
      end
    
      def sale_amount
        sale_amount_raw - sale_amount_raw % 1000
      end
    
      def sale_amount_without_tax
        sale_amount * 100 / 110
      end
    
      def taxable_purchase_amount
        query = <<EOF
          select jd.dc_type as dc_type, sum(jd.amount) as amount from journal_details jd
          inner join journals j on (j.id = jd.journal_id)
          inner join accounts a on (a.id = jd.account_id)
          where j.ym >= ? and j.ym <= ?
            and a.account_type = ?
            and jd.tax_rate = ?
          group by jd.dc_type
EOF
        query = JournalDetail.__send__(:sanitize_sql_array, [query, fiscal_year.start_year_month, fiscal_year.end_year_month, ACCOUNT_TYPE_EXPENSE, 0.1])
        result = JournalDetail.connection.select_all(query)
        
        Rails.logger.info result.inspect
        
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

  end
end
