module Reports
  class DividendReceivedLogic < BaseLogic

    def build_model
      ret = DividendReceivedModel.new
      ret.fully_owned_stocks = get_fully_owned_stocks(start_ym, end_ym)
      ret.fully_owned_stocks_amount = ret.fully_owned_stocks.inject(0){|sum, d| sum + d.amount}
      ret.partially_stocks = get_partially_owned_stocks(start_ym, end_ym)
      ret.partially_stocks_amount = ret.partially_stocks.inject(0){|sum, d| sum + d.amount}
      ret.etc_stocks = get_etc_stocks(start_ym, end_ym)
      ret.etc_stocks_amount = ret.etc_stocks.inject(0){|sum, d| sum + d.amount}
      ret
    end
    
    def get_fully_owned_stocks(ym_start, ym_end)
      get_stocks(ym_start, ym_end, SubAccount.where(:code => SUB_ACCOUNT_CODE_FULLY_OWNED_STOCKS))
    end
    
    def get_partially_owned_stocks(ym_start, ym_end)
      get_stocks(ym_start, ym_end, SubAccount.where(:code => SUB_ACCOUNT_CODE_PARTIALLY_OWNED_STOCKS))
    end
    
    def get_etc_stocks(ym_start, ym_end)
      get_stocks(ym_start, ym_end, SubAccount.where(:code => SUB_ACCOUNT_CODE_ETC_STOCKS))
    end
    
    def get_stocks(ym_start, ym_end, sub_account_id)
      stocks = JournalDetail.where(account_id: Account.where(code: ACCOUNT_CODE_DIVIDEND_RECEIVED), sub_account_id: sub_account_id).joins(:journal).where("journals.ym >= ? and journals.ym <= ?", ym_start, ym_end)      
    end
  end

  class DividendReceivedModel
    attr_accessor :fully_owned_stocks
    attr_accessor :partially_stocks
    attr_accessor :etc_stocks
    attr_accessor :fully_owned_stocks_amount
    attr_accessor :partially_stocks_amount
    attr_accessor :etc_stocks_amount
  end
end
