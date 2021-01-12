module Reports
  module ConsumptionTax
    # TODO TaxJp から消費税率を取得する
    class BaseLogic < Reports::BaseLogic

      protected

      # 当期の中間申告した金額を取得する
      def get_this_term_interim_amount(account_code, sub_account_id = nil)
        query = <<EOF
          select sum(jd.amount) as amount from journal_details jd
          inner join journals j on (j.id = jd.journal_id)
          inner join accounts a on (a.id = jd.account_id)
          where j.ym >= ? and j.ym <= ?
            and a.code = ?
            and jd.sub_account_id = ?
            and jd.dc_type = a.dc_type
            and jd.settlement_type = ?
EOF
        result = execute_query(query, start_ym, end_ym, account_code, sub_account_id, SETTLEMENT_TYPE_HALF)
        result.first['amount']
      end

      # 課税仕入額（税抜）
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
        result = execute_query(query, start_ym, end_ym, ACCOUNT_TYPE_EXPENSE, tax_rate)
        
        ret = 0
        result.each do |hash|
          if hash['dc_type'] == DC_TYPE_DEBIT
            ret += hash['amount']
          else
            ret -= hash['amount']
          end
        end

        ret
      end

    end

    class BaseModel
      attr_accessor :company, :fiscal_year
      attr_accessor :sale_amount, :reduced_sale_amount
      attr_accessor :taxable_purchase_amount, :reduced_taxable_purchase_amount

      def company_name
        company.name
      end
    
      def total_sale_amount
        sale_amount + reduced_sale_amount
      end

      def standard_sale_amount
        sale_amount - sale_amount % 1000
      end
    
      def starndard_reduced_sale_amount
        reduced_sale_amount - reduced_sale_amount % 1000
      end

      def total_standard_sale_amount
        standard_sale_amount + starndard_reduced_sale_amount
      end

      # 課税標準額に6.24％を掛けて消費税額を計算
      def reduced_sale_tax_amount
        (starndard_reduced_sale_amount * 0.0624).to_i
      end

      # 課税標準額に7.8％を掛けて消費税額を計算
      def sale_tax_amount
        (standard_sale_amount * 0.078).to_i
      end

      def total_sale_tax_amount
        sale_tax_amount + reduced_sale_tax_amount
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
        ret = sale_tax_amount - total_taxable_purchase_tax_amount
        ret -= ret % 100
        ret
      end
    
      def total_local_tax_amount
        ret = (total_tax_amount * 22 / 78).to_i
        ret -= ret % 100
        ret
      end
    end

  end
end
