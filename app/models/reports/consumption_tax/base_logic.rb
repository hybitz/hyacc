module Reports
  module ConsumptionTax
    # TODO TaxJp から消費税率を取得する
    class BaseLogic < Reports::BaseLogic

      protected

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

  end
end
