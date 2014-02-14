# -*- encoding : utf-8 -*-
#
# $Id: name_and_value.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class NameAndValue
  attr_reader :name
  attr_reader :value
  
  def initialize(name, value)
    @name = name
    @value = value
  end
end
