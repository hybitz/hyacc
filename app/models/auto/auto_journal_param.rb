module Auto
  class AutoJournalParam
    attr_reader :auto_journal_type
    attr_reader :user
    
    def initialize( auto_journal_type, user = nil )
      @auto_journal_type = auto_journal_type.to_i
      @user = user
    end

  end
end
