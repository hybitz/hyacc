module Auto::TransferJournal
  
  class InternalTradeParam < Auto::AutoJournalParam
    include HyaccConstants
    
    attr_reader :journal_header
    
    def initialize( journal_header )
      super( AUTO_JOURNAL_TYPE_INTERNAL_TRADE )
      @journal_header = journal_header
    end

  end
end
