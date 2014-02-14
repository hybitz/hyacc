# -*- encoding : utf-8 -*-
#
# $Id: rent_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class RentFinder < Base::Finder
  
  def initialize( user )
    super(user)
    @deleted = false
  end

  def list
    Rent.paginate(
      :page=>@page > 0 ? @page : 1,
      :conditions=>make_conditions,
      :order=>'status, ymd_end desc',
      :per_page=>@slips_per_page)
  end

private
  def make_conditions
    ret = []
    unless @deleted.nil?
      ret << 'status=?'
      if @deleted
        ret << RENT_STATUS_TYPE_STOP
      else
        ret << RENT_STATUS_TYPE_USE
      end
    end
    ret
  end
end
