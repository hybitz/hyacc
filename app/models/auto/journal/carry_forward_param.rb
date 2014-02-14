# -*- encoding : utf-8 -*-
#
# $Id: carry_forward_param.rb 2474 2011-03-23 15:28:08Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::Journal
    
  class CarryForwardParam < Auto::AutoJournalParam
    attr_reader :fiscal_year

    def initialize( fiscal_year, user )
      super( HyaccConstants::AUTO_JOURNAL_TYPE_CARRY_FORWARD, user )
      @fiscal_year = fiscal_year
    end
  end
end
