# -*- encoding : utf-8 -*-
#
# $Id: housework.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Housework < ActiveRecord::Base
  has_many :housework_details, :dependent=>:destroy
  has_many :journal_headers, :dependent=>:destroy
  validates_presence_of :fiscal_year
  accepts_nested_attributes_for :journal_headers
end
