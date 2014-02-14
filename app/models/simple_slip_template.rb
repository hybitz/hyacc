# coding: UTF-8
#
# $Id: simple_slip_template.rb 3062 2013-06-21 03:10:44Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class SimpleSlipTemplate < ActiveRecord::Base
  include HyaccConstants
  
  belongs_to :account
  belongs_to :branch
  
  validates_presence_of :remarks, :keywords

  def dc_type_name
    DC_TYPES[dc_type]
  end
  
  def focus_on_complete_name
    FOCUS_ON_COMPLETES[focus_on_complete]
  end
  
  def sub_account
    if self.sub_account_id
      account.get_sub_account_by_id(self.sub_account_id)
    end
  end
  
  def tax_type_name
    TAX_TYPES[tax_type]
  end
  
end
