# coding: UTF-8
#
# $Id: monthly_ledger.rb 2966 2012-12-21 05:52:07Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class MonthlyLedger
    include HyaccConstants

    attr_accessor :ym
    attr_accessor :amount_debit
    attr_accessor :amount_credit

  def has_amount
    self.amount_debit.to_i + self.amount_credit.to_i > 0
  end
end
