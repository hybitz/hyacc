module Auto::TransferJournal
  
  class InternalTradeParam < Auto::AutoJournalParam
    include HyaccConstants
    
    attr_reader :journal
    
    def initialize(journal)
      super(AUTO_JOURNAL_TYPE_INTERNAL_TRADE)
      @journal = journal
    end

  end
end
