module Auto::Journal
    
  class PayrollParam < Auto::AutoJournalParam
    attr_reader :payroll
    attr_reader :user
    
    def initialize( payroll, user )
      super( HyaccConst::AUTO_JOURNAL_TYPE_PAYROLL )
      @payroll = payroll
      @user = user
    end
  end
end
