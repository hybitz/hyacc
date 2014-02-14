# -*- encoding : utf-8 -*-
#
# $Id: internal_trade_param.rb 2474 2011-03-23 15:28:08Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
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
