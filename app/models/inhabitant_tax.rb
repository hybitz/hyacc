# -*- encoding : utf-8 -*-
#
# $Id: inhabitant_tax.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'date'

class InhabitantTax < ActiveRecord::Base
  belongs_to :employee
  
  validates_presence_of :ym, :employee_id, :message=>"を入力して下さい。"
  validates_format_of :amount,
                      :with => /^[0-9]{1,}$/, :message=>"は数値で入力して下さい。"
  
  # Classメソッドを使用する
  class << self
    def new_by_array(arr)
      arr.map! do |elem|
        NKF::nkf('-S -w',elem) if elem
      end
      self.new(
                :ym => arr[0],
                :employee_id => arr[1],
                :amount => arr[2]
              )
    end
  end
end
