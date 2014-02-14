# -*- encoding : utf-8 -*-
#
# $Id: depreciation_rate_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class DepreciationRateFinder < Base::Finder
  def list
    DepreciationRate.find(:all, :order=>'durable_years')
  end
end
