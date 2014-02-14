# -*- encoding : utf-8 -*-
#
# $Id: career_statement_helper.rb 2469 2011-03-23 14:57:42Z ichy $
# Product: hyacc
# Copyright 2009-2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module CareerStatementHelper
  include HyaccConstants
  
  def company_label(company_type)
    return '屋号' if company_type == COMPANY_TYPE_PERSONAL
    '会社名'
  end
end
