# coding: UTF-8
#
# $Id: customer.rb 2991 2013-02-15 07:27:01Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Customer < ActiveRecord::Base
  include HyaccConstants
  has_many :customer_names, :dependent=>:destroy
  accepts_nested_attributes_for :customer_names, :allow_destroy=>true
  after_save :reset_account_cache

  def name
    current = CustomerName.get_current(id)
    current.name if current
  end

  def formal_name
    current = CustomerName.get_current(id)
    current.formal_name if current
  end
  
  def reset_account_cache
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_CUSTOMER)
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_ORDER_ENTRY)
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_ORDER_PLACEMENT)
  end
end
