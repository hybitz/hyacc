module Reports
  module ConsumptionTax

    class Form1Logic < BaseLogic

      def build_model
        Rails.logger.info fiscal_year.fiscal_year

        ret = Form1Model.new
    
        ret.company = Company.find(finder.company_id)
        ret.fiscal_year = fiscal_year
        ret.sale_amount = get_this_term_amount(ACCOUNT_CODE_SALE)
        ret.reduced_sale_amount = 0
        ret.taxable_purchase_amount = get_taxable_purchase_amount(0.1)
        ret.reduced_taxable_purchase_amount = get_taxable_purchase_amount(0.08)
        ret.interim_tax_amount = get_this_term_interim_amount(ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE, CONSUMPTION_TAX_TYPE_NATIONAL)
        ret.interim_local_tax_amount = get_this_term_interim_amount(ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE, CONSUMPTION_TAX_TYPE_LOCAL)
        ret.standard_sale_amount_of_base_period = get_standard_sale_amount_of_base_period
        ret
      end

      def get_standard_sale_amount_of_base_period
        a = Account.where(code: ACCOUNT_CODE_SALE, deleted: false).first

        base_fiscal_year = fiscal_year.fiscal_year - 2
        start_ym = HyaccDateUtil.get_start_year_month_of_fiscal_year(base_fiscal_year, company.start_month_of_fiscal_year)
        end_ym = HyaccDateUtil.get_end_year_month_of_fiscal_year(base_fiscal_year, company.start_month_of_fiscal_year)

        VMonthlyLedger.net_sum(start_ym, end_ym, a.id)
      end

    end

    class Form1Model < BaseModel
      attr_accessor :interim_tax_amount, :interim_local_tax_amount
      # 基準期間の課税売上高
      attr_accessor :standard_sale_amount_of_base_period

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
