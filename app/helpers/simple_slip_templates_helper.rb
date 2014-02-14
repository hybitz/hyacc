# -*- encoding : utf-8 -*-
#
# $Id: simple_slip_templates_helper.rb 2469 2011-03-23 14:57:42Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module SimpleSlipTemplatesHelper
  @@focus_field_names = {
    :amount => '金額',
    :tax_amount => '消費税額'
  }
  
  
  def focus_field_name(focus_on_complete)
    if focus_on_complete
      @@focus_field_names[focus_on_complete.to_sym]
    end
  end
end
