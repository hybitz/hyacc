# -*- encoding : utf-8 -*-
#
# $Id: depreciation_rates_controller.rb 2467 2011-03-23 14:56:39Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class DepreciationRatesController < Base::BasicMasterController
  view_attribute :finder, :class=>DepreciationRateFinder, :only=>:index
  view_attribute :model, :class=>DepreciationRate
  
  def index
    @list = finder.list
    respond_to do |format|
      format.html
      format.xml  { render :xml => @list }
    end
  end
end
