# -*- encoding : utf-8 -*-
#
# $Id: customer_name.rb 2771 2012-01-07 17:00:08Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require "date"

class CustomerName < ActiveRecord::Base
  belongs_to :customer
  
  validates_presence_of :formal_name
  validates_presence_of :name
  
  attr_accessor :_destroy
  
  def self.get_current(customer_id)
    self.get_at(customer_id, Date.today)
  end
  
  def self.get_at(customer_id, date)
    CustomerName.find(:first,
      :conditions=>['customer_id=? and start_date <= ?', customer_id, date],
      :order=>"start_date desc")
  end
end
