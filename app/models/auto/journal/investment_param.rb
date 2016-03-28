module Auto::Journal
    
  class InvestmentParam < Auto::AutoJournalParam
    attr_reader :investment
    
    def initialize( investment, user )
      super(HyaccConstants::AUTO_JOURNAL_TYPE_INVESTMENT, user)
      @investment = investment
    end
  end
end
