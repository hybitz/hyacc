# -*- encoding : utf-8 -*-
#
# $Id: debt_finder.rb 1349 2009-11-25 11:40:48Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class EmployeeFinder < Base::Finder

  def enable_employee_id
    false
  end
  
  def list
    Employee.paginate :page=>@page > 0 ? @page : 1, :per_page=>@slips_per_page
  end
end
