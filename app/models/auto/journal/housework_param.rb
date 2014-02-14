# -*- encoding : utf-8 -*-
#
# $Id: housework_param.rb 2474 2011-03-23 15:28:08Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::Journal
    
  class HouseworkParam < Auto::AutoJournalParam
    attr_reader :housework
    
    def initialize( housework, user )
      super( HyaccConstants::AUTO_JOURNAL_TYPE_HOUSEWORK, user )
      @housework = housework
    end
  end
end
