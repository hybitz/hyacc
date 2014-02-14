# -*- encoding : utf-8 -*-
#
# $Id: input_frequency.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class InputFrequency < ActiveRecord::Base
    
  def self.save_input_frequency(user_id, input_type, input_value="", input_value2="")
    f = InputFrequency.find(
      :first,
      :conditions=>['user_id=? and input_type=? and input_value=? and input_value2=?',
          user_id,
          input_type,
          input_value,
          input_value2])

    unless f
      f = InputFrequency.new
      f.user_id = user_id
      f.input_type = input_type
      f.input_value = input_value.to_s
      f.input_value2 = input_value2.to_s
      f.frequency = 0
    end

    f.frequency += 1
    f.save!
  end
end
