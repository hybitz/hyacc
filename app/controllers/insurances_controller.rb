# -*- encoding : utf-8 -*-
#
# $Id: insurances_controller.rb 2625 2011-08-19 08:04:53Z hiro $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class InsurancesController < Base::HyaccMasterController
  available_for :type=>:company_type, :except=>COMPANY_TYPE_PERSONAL
  view_attribute :finder, :class=>InsuranceFinder, :only=>:index
  view_attribute :model, :class=>Insurance
  view_attribute :prefectures, :only=>:index
end
