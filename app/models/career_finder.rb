# coding: UTF-8
#
# $Id: career_finder.rb 2925 2012-09-21 03:51:20Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CareerFinder < Base::Finder
  
  def list
    Career.paginate(
      :page=>@page > 0 ? @page : 1,
      :conditions=>make_conditions,
      :order=>"start_from",
      :per_page=>@slips_per_page)
  end

private
  def make_conditions
    ret = []
    if @employee_id > 0
      ret << 'employee_id=?'
      ret << @employee_id
    end
    ret
  end
end
