# -*- encoding : utf-8 -*-
#
# $Id: account_control.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AccountControl < ActiveRecord::Base
  belongs_to :account
end
