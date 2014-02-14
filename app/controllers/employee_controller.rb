# coding: UTF-8
#
# $Id: employee_controller.rb 3177 2014-01-15 03:53:43Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class EmployeeController < Base::HyaccController
  available_for :type => :company_type, :except => COMPANY_TYPE_PERSONAL
  view_attribute :title => '従業員'
  view_attribute :finder, :class=>EmployeeFinder, :only=>:index
  view_attribute :branches, :except=>[:index, :show, :destroy]
  
  def index
    @employees = finder.list
    setup_view_attributes
  end
  
  def add_employee_history
    @employee_history = EmployeeHistory.new
  end

  def add_branch
    @branches_employee = BranchesEmployee.new
  end
 
  def edit
    @e = Employee.find(params[:id])
    setup_view_attributes
  end

  def update
    @e = Employee.find(params[:id])

    begin
      @e.transaction do
        EmployeeHistory.delete_all("employee_id=#{@e.id}")
        BranchesEmployee.delete_all("employee_id=#{@e.id}")
        @e.update_attributes!(params[:e])
      end

      flash[:notice] = '従業員を更新しました。'
      render :partial=>'common/reload_dialog'

    rescue Exception => e
      handle(e)
      setup_view_attributes
      render :action => 'edit'
    end
  end

  def destroy
    id = params[:id].to_i
    Employee.find(id).update_attributes(:deleted => true)

    # 削除したユーザがログインユーザ自身の場合は、ログアウト
    if current_user.employee.id == id
      redirect_to :controller=>:login, :action=>:logout
    else
      flash[:notice] = '従業員を削除しました。'
      redirect_to :action=>:index
    end
  end

  private

  def setup_view_attributes
    @business_offices = current_user.company.business_offices
  end
end
