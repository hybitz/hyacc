module Reports
  class DividendReceivedLogic
    include HyaccDateUtil
    
    def get_dividend_received_model(finder)
      model = DividendReceivedModel.new
      ym_start = get_start_year_month_of_fiscal_year( finder.fiscal_year, finder.start_month_of_fiscal_year)
      ym_end = get_end_year_month_of_fiscal_year( finder.fiscal_year, finder.start_month_of_fiscal_year)
      model.fully_owned_stocks = get_fully_owned_stocks(ym_start, ym_end)
      model.fully_owned_stocks_amount = model.fully_owned_stocks.inject(0){|sum, d| sum + d.amount}
      model.partially_stocks = get_partially_owned_stocks(ym_start, ym_end)
      model.partially_stocks_amount = model.partially_stocks.inject(0){|sum, d| sum + d.amount}
      model.etc_stocks = get_etc_stocks(ym_start, ym_end)
      model.etc_stocks_amount = model.etc_stocks.inject(0){|sum, d| sum + d.amount}
      model
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
      stocks = JournalDetail.where(:account_id => Account.where(:code => ACCOUNT_CODE_DIVIDEND_RECEIVED), :sub_account_id => sub_account_id).joins(:journal_header).where("journal_headers.ym >= ? and journal_headers.ym <= ?", ym_start, ym_end)      
    end
  end
end
