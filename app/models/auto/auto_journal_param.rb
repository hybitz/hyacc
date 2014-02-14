# -*- encoding : utf-8 -*-
#
# $Id: auto_journal_param.rb 2473 2011-03-23 15:27:41Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
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
