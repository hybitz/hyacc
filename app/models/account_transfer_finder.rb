# -*- encoding : utf-8 -*-
#
# $Id: account_transfer_finder.rb 2594 2011-05-20 07:29:40Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AccountTransferFinder < JournalFinder
  attr_accessor :to_account_id
  attr_accessor :to_sub_account_id

  def initialize(user)
    super(user)
    @to_account_id = 0
    @to_sub_account_id = 0
  end
end
