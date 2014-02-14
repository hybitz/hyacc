# -*- encoding : utf-8 -*-
#
# $Id: notification_helper.rb 2469 2011-03-23 14:57:42Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module NotificationHelper
  
  def get_debt_count(debts, include_closed=false)
    return debts.size if include_closed
    return debts.select{|debt| debt.closed_id.nil? }.size
  end
end
