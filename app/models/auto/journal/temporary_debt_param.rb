# coding: UTF-8
#
# $Id: temporary_debt_param.rb 3340 2014-02-01 02:50:49Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::Journal
    
  class TemporaryDebtParam < Auto::AutoJournalParam
    attr_reader :params
    attr_reader :user
    
    def initialize( params, user )
      super( HyaccConstants::AUTO_JOURNAL_TYPE_TEMPORARY_DEBT )
      @params = params
      @user = user
    end
  end
end
