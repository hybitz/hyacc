# coding: UTF-8
#
# $Id: career.rb 3168 2014-01-01 12:39:53Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#

class Career < ActiveRecord::Base
  belongs_to :employee
  belongs_to :customer  
  before_save :update_names

  # マスタの名称を明細自身に設定する
  def update_names
    self.customer_name = CustomerName.get_at(customer_id, end_to).formal_name
    HyaccLogger.debug CustomerName.get_at(customer_id, end_to).formal_name
  end
  
  def duration_ym
    duration = (end_to_or_today - start_from).to_i
    return duration/365, duration%365/31 + (duration%365%31 > 0 ? 1 : 0)
  end
  
  def is_up_to_today
    today = Date.today
    end_to - today > 0
  end
  
  def end_to_or_today
    if is_up_to_today
      Date.today
    else
      end_to
    end
  end
end
