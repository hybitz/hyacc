# -*- encoding : utf-8 -*-
#
# $Id: social_expense_detail_model.rb 2477 2011-03-23 15:29:30Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Reports
  class SocialExpenseDetailModel
    attr_accessor :account
    attr_accessor :amount
    attr_accessor :deduction_amount
    attr_accessor :social_expense_amount
    
    def initialize
      @amount = 0;
      @deduction_amount = 0;
      @social_expense_amount = 0;
    end
  end  
end
