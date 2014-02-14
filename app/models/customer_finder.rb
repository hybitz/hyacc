# -*- encoding : utf-8 -*-
#
# $Id: customer_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CustomerFinder < Base::Finder
  
  def initialize( user )
    super(user)
    @deleted = false
  end

  def list
    Customer.paginate(
      :page=>@page > 0 ? @page : 1,
      :conditions=>make_conditions,
      :order=>"code",
      :per_page=>@slips_per_page)
  end

private
  def make_conditions
    ret = []
    unless @deleted.nil?
      ret << 'deleted=?'
      ret << @deleted
    end
    ret
  end
end
