# -*- encoding : utf-8 -*-
#
# $Id: depreciation.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Depreciation < ActiveRecord::Base
  belongs_to :asset
  has_many :journal_headers, :dependent=>:destroy
  accepts_nested_attributes_for :journal_headers
  
  def amount_depreciated
    amount_at_start - amount_at_end
  end
end
