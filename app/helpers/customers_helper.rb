# -*- encoding : utf-8 -*-
#
# $Id: customers_helper.rb 2469 2011-03-23 14:57:42Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module CustomersHelper
  
  def render_checkmark(check)
    if check
      image_tag('/images/checkmark.gif', :size=>'16x16')
    end
  end
end
