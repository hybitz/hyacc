# -*- encoding : utf-8 -*-
#
# $Id: customer_name.rb 1745 2010-02-21 14:54:10Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require "date"

class EmployeeHistory < ActiveRecord::Base
  belongs_to :employee
  
  def self.get_current(employee_id)
    get_at(employee_id, Date.today)
  end
  
  def self.get_at(employee_id, date)
    EmployeeHistory.find(:first,
      :conditions=>['employee_id=? and start_date <= ?', employee_id, date],
      :order=>"start_date desc")
  end
  
end
