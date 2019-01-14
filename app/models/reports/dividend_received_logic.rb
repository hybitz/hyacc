module Reports
  class DividendReceivedLogic < BaseLogic

    def build_model
      ret = DividendReceivedModel.new
      ret.fully_owned_stocks = get_fully_owned_stocks(start_ym, end_ym)
      ret.fully_owned_stocks_amount = ret.fully_owned_stocks.inject(0){|sum, d| sum + d.amount}
      ret.partially_stocks = get_partially_owned_stocks(start_ym, end_ym)
      ret.partially_stocks_amount = ret.partially_stocks.inject(0){|sum, d| sum + d.amount}
      ret.etc_stocks = get_etc_stocks(start_ym, end_ym)
      ret.non_dominant_stocks = get_non_dominant_stocks(start_ym, end_ym)
      ret
    end
    
    def get_fully_owned_stocks(ym_start, ym_end)
      get_stocks(ym_start, ym_end, SubAccount.where(code: SUB_ACCOUNT_CODE_FULLY_OWNED_STOCKS))
    end
    
    def get_partially_owned_stocks(ym_start, ym_end)
      get_stocks(ym_start, ym_end, SubAccount.where(code: SUB_ACCOUNT_CODE_PARTIALLY_OWNED_STOCKS))
    end
    
    def get_etc_stocks(ym_start, ym_end)
      stocks = get_stocks(ym_start, ym_end, SubAccount.where(code: SUB_ACCOUNT_CODE_ETC_STOCKS))

      ret = []
      [stocks.size, 2].max.times do |i|
        jd = stocks[i]
        detail = DividendReceivedDetailModel.new
        detail.amount = jd.try(:amount) || 0
        detail.profit_amount = 0
        ret << detail
      end
      ret
    end
    
    def get_non_dominant_stocks(ym_start, ym_end)
      stocks = get_stocks(ym_start, ym_end, SubAccount.where(code: SUB_ACCOUNT_CODE_NON_DOMINANT_STOCKS))

      ret = []
      [stocks.size, 2].max.times do |i|
        jd = stocks[i]
        detail = DividendReceivedDetailModel.new
        detail.amount = jd.try(:amount) || 0
        detail.profit_amount = 0
        ret << detail
      end
      ret
    end

    def get_stocks(ym_start, ym_end, sub_account_id)
      stocks = JournalDetail.where(account_id: Account.where(code: ACCOUNT_CODE_DIVIDEND_RECEIVED), sub_account_id: sub_account_id).joins(:journal).where("journals.ym >= ? and journals.ym <= ?", ym_start, ym_end)      
    end
  end

  class DividendReceivedModel
    attr_accessor :fully_owned_stocks, :fully_owned_stocks_amount
    attr_accessor :partially_stocks, :partially_stocks_amount
    attr_accessor :etc_stocks
    attr_accessor :non_dominant_stocks

    def etc_amount
      etc_stocks.inject(0){|sum, d| sum + d.amount}
    end
    
    def etc_profit_amount
      etc_stocks.inject(0){|sum, d| sum + d.profit_amount}
    end

    def etc_total_amount
      etc_stocks.inject(0){|sum, d| sum + d.total_amount}
    end

    def non_dominant_amount
      non_dominant_stocks.inject(0){|sum, d| sum + d.amount}
    end
    
    def non_dominant_profit_amount
      non_dominant_stocks.inject(0){|sum, d| sum + d.profit_amount}
    end

    def non_dominant_total_amount
      non_dominant_stocks.inject(0){|sum, d| sum + d.total_amount}
    end

    # 損金不算入額
    def non_deductible_amount
      etc_total_amount * 0.5 + non_dominant_total_amount * 0.2
    end
  end

  class DividendReceivedDetailModel
    attr_accessor :note
    attr_accessor :amount
    attr_accessor :profit_amount

    def total_amount
      amount - profit_amount
    end
  end
end
