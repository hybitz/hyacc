# -*- encoding : utf-8 -*-
#
# $Id: transfer_from_detail_param.rb 2474 2011-03-23 15:28:08Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::TransferJournal
  
  class TransferFromDetailParam < Auto::AutoJournalParam
    include HyaccConstants
    
    attr_reader :journal_detail
    
    def initialize( auto_journal_type, journal_detail )
      super( auto_journal_type )
      @journal_detail = journal_detail
    end

  end
end
