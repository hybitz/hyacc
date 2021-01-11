module Reports
  module ConsumptionTax

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
        sale_tax_amount - total_taxable_purchase_tax_amount
      end
    
      def total_local_tax_amount
        local_tax_amount = (total_tax_amount * 22 / 78).to_i
        local_tax_amount - local_tax_amount / 100
      end
    end

  end
end
