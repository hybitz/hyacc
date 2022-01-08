module Auto::Journal
    
  class DeemedTaxParam < Auto::AutoJournalParam
    attr_reader :fiscal_year
    
    def initialize( fiscal_year, user )
      super( HyaccConst::AUTO_JOURNAL_TYPE_DEEMED_TAX, user )
      @fiscal_year = fiscal_year
    end
  end
end
