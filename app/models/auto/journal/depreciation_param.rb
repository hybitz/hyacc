# -*- encoding : utf-8 -*-
#
# $Id: depreciation_param.rb 2474 2011-03-23 15:28:08Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::Journal
    
  class DepreciationParam < Auto::AutoJournalParam
    attr_reader :depreciation
    attr_reader :user
    
    def initialize( depreciation, user )
      super( HyaccConstants::AUTO_JOURNAL_TYPE_DEPRECIATION, user )
      @depreciation = depreciation
    end
  end
end
