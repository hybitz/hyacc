# -*- encoding : utf-8 -*-
#
# $Id: trade_account_payable_detail_model.rb 2477 2011-03-23 15:29:30Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Reports
  class TradeAccountPayableDetailModel
    attr_accessor :account
    attr_accessor :name
    attr_accessor :address
    attr_accessor :amount_at_end
    attr_accessor :remarks
    
    def initialize
      @amount_at_end = 0
    end
    
  end
end
