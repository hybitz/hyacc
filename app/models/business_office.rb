# -*- encoding : utf-8 -*-
#
# $Id: business_office.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BusinessOffice < ActiveRecord::Base
  belongs_to :company
end
