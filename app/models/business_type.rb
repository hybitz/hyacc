# -*- encoding : utf-8 -*-
#
# $Id: business_type.rb 2768 2011-12-29 17:00:06Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BusinessType < ActiveRecord::Base
  
  def deemed_tax_percent
    deemed_tax_ratio * 100
  end
end
