module DeemedTax
  class DeemedTaxLogic
    include HyaccConstants
    
    def initialize(fiscal_year=nil)
      @fiscal_year = fiscal_year
    end

    def get_deemed_tax_model(ym_from=nil, ym_to=nil)
      ym_from = @fiscal_year.start_year_month unless ym_from
      ym_to = @fiscal_year.end_year_month unless ym_to

      dtm = DeemedTaxModel.new
      
      # 会計年度
      dtm.fiscal_year = @fiscal_year
      
      # 事業区分
      dtm.business_type = @fiscal_year.company.business_type
      
      # 課税売上高
      profit_account = Account.where(:account_type => ACCOUNT_TYPE_PROFIT, :parent_id => nil).first
      dtm.imposition_sales_amount = make_up_sales_amount(ym_from, ym_to, profit_account)
      
      # 課税標準額
      dtm.imposition_base_amount = calc_imposition_base_amount(dtm.imposition_sales_amount)

      # 消費税
      dtm.tax_amount = calc_tax_amount(dtm.imposition_base_amount, dtm.business_type.deemed_tax_ratio)
      
      # 地方消費税
      dtm.local_tax_amount = calc_local_tax_amount(dtm.tax_amount)
      
      # 納税額
      dtm.total_tax_amount = calc_total_tax_amount(dtm.tax_amount, dtm.local_tax_amount)

      # 仕訳金額
      dtm.journal_amount = calc_journal_amount

      dtm
    end
    
    # 課税標準額を計算する
    def calc_imposition_base_amount(imposition_sales_amount)
      return 0 unless imposition_sales_amount > 0

      ret = (imposition_sales_amount * 100 / 105).floor
      
      # 1000円未満切り捨て
      ret / 1000 * 1000
    end
    
    # 消費税（国税分）を計算する
    def calc_tax_amount(imposition_base_amount, deemed_tax_ratio)
      ((imposition_base_amount * 0.04).floor * deemed_tax_ratio).floor
    end
    
    # 地方消費税を計算する
    def calc_local_tax_amount(tax_amount)
      (tax_amount * 0.25).floor
    end
    
    # 消費税納税額を計算する
    def calc_total_tax_amount(tax_amount, local_tax_amount)
      tax_amount + local_tax_amount
    end
    
    # 仕訳上の金額を計算する
    def calc_journal_amount
      @fiscal_year.get_deemed_tax_journals.inject(0){|total, jh| total + jh.amount }
    end

    private

    def make_up_sales_amount(ym_from, ym_to, profit_account)
      amount = 0
  
      unless profit_account.tax_type == TAX_TYPE_NONTAXABLE
        amount += VMonthlyLedger.get_net_sum_amount(ym_from, ym_to, profit_account.id, 0, 0, false)
      end
      
      profit_account.children.each do |a|
        amount += make_up_sales_amount(ym_from, ym_to, a)
      end
      
      amount
    end
  end
end
