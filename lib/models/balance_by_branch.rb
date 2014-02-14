# -*- encoding : utf-8 -*-
#
# $Id: balance_by_branch.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BalanceByBranch
  attr_accessor :branch_id
  attr_accessor :amount_debit
  attr_accessor :amount_credit
  
  def initialize
    @branch_id = 0
    @amount_debit = 0
    @amount_credit = 0
  end
  
end
