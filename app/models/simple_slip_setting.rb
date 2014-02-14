# -*- encoding : utf-8 -*-
#
# $Id: simple_slip_setting.rb 2824 2012-02-17 05:58:06Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class SimpleSlipSetting < ActiveRecord::Base
  
  validates :shortcut_key, :format => { :with => /Ctrl\+[0-9]/ }
  
  def account
    Account.get(account_id)
  end
end
