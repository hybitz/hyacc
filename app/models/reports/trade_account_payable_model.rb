module Reports
  class TradeAccountPayableModel
    attr_accessor :details
    attr_reader :amountSum
    attr_reader :amountSumByAccount
    
    def initialize
      @details = []
      @amountSum = 0
      @amountSumByAccount = {}
    end
    
    def add_detail( detail )
      @details << detail
      @amountSum += detail.amount_at_end

      # 科目ごとの集計
      @amountSumByAccount[detail.account.code] = 0 unless @amountSumByAccount[detail.account.code]
      @amountSumByAccount[detail.account.code] += detail.amount_at_end 
    end
  end
end
