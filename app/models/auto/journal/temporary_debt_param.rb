module Auto::Journal
    
  class TemporaryDebtParam < Auto::AutoJournalParam
    attr_reader :params
    attr_reader :user
    
    def initialize( params, user )
      super( HyaccConst::AUTO_JOURNAL_TYPE_TEMPORARY_DEBT )
      @params = params
      @user = user
    end
  end
end
