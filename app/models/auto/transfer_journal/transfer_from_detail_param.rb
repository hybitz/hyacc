module Auto::TransferJournal
  
  class TransferFromDetailParam < Auto::AutoJournalParam
    attr_reader :journal_detail
    
    def initialize( auto_journal_type, journal_detail )
      super( auto_journal_type )
      @journal_detail = journal_detail
    end

  end
end
