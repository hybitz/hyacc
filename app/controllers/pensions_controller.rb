# coding: UTF-8
#
# $Id: pensions_controller.rb 3113 2013-08-06 04:01:04Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class PensionsController < Base::HyaccMasterController
  available_for :type => :company_type, :except => COMPANY_TYPE_PERSONAL
  view_attribute :finder, :class => PensionFinder, :only => :index
  view_attribute :model, :class => Pension
  view_attribute :prefectures, :only => :index
end
