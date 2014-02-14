# coding: UTF-8
#
# $Id: bank_account.rb 2915 2012-08-31 08:15:35Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BankAccount < ActiveRecord::Base
  include HyaccConstants
  after_save :reset_account_cache
  
  belongs_to :bank
  belongs_to :bank_office

  def bank_name
    return nil unless bank
    bank.name
  end
  
  def bank_office_name
    return nil unless bank_office
    bank_office.name
  end

  def financial_account_type_name
    FINANCIAL_ACCOUNT_TYPES[financial_account_type]
  end

  def reset_account_cache
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_SAVING_ACCOUNT)
  end
  
end
