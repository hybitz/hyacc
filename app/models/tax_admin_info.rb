# -*- encoding : utf-8 -*-
#
# $Id: tax_admin_info.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class TaxAdminInfo < ActiveRecord::Base
  belongs_to :journal_header
end
