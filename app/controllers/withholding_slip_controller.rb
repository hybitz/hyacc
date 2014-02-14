# coding: UTF-8
#
# $Id: withholding_slip_controller.rb 3160 2014-01-01 06:58:14Z ichy $
# Product: hyacc
# Copyright 2013-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class WithholdingSlipController < Base::HyaccController
  include JournalUtil

  available_for :type=>:company_type, :except=>COMPANY_TYPE_PERSONAL
  view_attribute :title => '源泉徴収'
  view_attribute :finder, :class=>WithholdingSlipFinder
  view_attribute :ym_list
  view_attribute :report_types
  view_attribute :employees

  def list
    return unless finder.commit
    begin
      case finder.report_type
      when REPORT_TYPE_WITHHOLDING_SUMMARY
        render_withholding_summary
      when REPORT_TYPE_WITHHOLDING_DETAILS
         if validate_params_details
           render_withholding_details
         else
           render :list
         end
      end
    rescue Exception=>e
      handle(e)
      render :list
    end
  end
  
  
private
  def validate_params_details
    if @finder.employee_id == 0
      flash[:notice] = '従業員を選択してください。'
      return false
    end
    return true
  end
  
  def render_withholding_summary
    render :withholding_summary
  end
  
  def render_withholding_details
    logic = Reports::WithholdingDetailLogic.new(finder)
    @data = logic.get_withholding_info
    render :withholding_details
  end
  
end
