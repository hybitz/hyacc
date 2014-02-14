# coding: UTF-8
#
# $Id: career_statement_controller.rb 3192 2014-01-21 14:17:19Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CareerStatementController < Base::HyaccController
  view_attribute :title => '業務経歴書'
  view_attribute :finder, :class=>CareerFinder, :only=>:index
  view_attribute :employees, :only=>[:index]
  
  def index
    @employees = Employee.where(:company_id => current_user.company_id).paginate :page=>params[:page], :per_page=>20
  end

  def show
    @e = Employee.find(params[:id])
    @careers = Career.find_all_by_employee_id(@e.id, :order=>"start_from, end_to")
  end
end
