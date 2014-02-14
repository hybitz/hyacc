# -*- encoding : utf-8 -*-
#
# $Id: 20100408111829_change_sub_account_type_of_receivable.rb 2125 2010-04-13 01:19:16Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class ChangeSubAccountTypeOfReceivable < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    a = Account.find_by_code('1551')
    if a
      a.sub_account_type = SUB_ACCOUNT_TYPE_ORDER_ENTRY
      a.save!
    end
  end

  def self.down
  end
end
