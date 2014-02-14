# -*- encoding : utf-8 -*-
#
# $Id: payroll_param.rb 2474 2011-03-23 15:28:08Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::Journal
    
  class PayrollParam < Auto::AutoJournalParam
    attr_reader :payroll
    attr_reader :user
    
    def initialize( payroll, user )
      super( HyaccConstants::AUTO_JOURNAL_TYPE_PAYROLL )
      @payroll = payroll
      @user = user
    end
  end
end
