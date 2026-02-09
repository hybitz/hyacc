module Auto::Journal
    
  class DepreciationParam < Auto::AutoJournalParam
    attr_reader :depreciation
    attr_reader :user
    
    def initialize( depreciation, user )
      super( HyaccConst::AUTO_JOURNAL_TYPE_DEPRECIATION, user )
      @depreciation = depreciation
    end
  end
end
