# coding: UTF-8
#
# $Id: notification_controller.rb 3034 2013-06-21 02:19:28Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class NotificationController < Base::HyaccController
  require 'uri'
  require 'gcalapi'
  require 'googlecalendar/auth_sub_util'
  require 'googlecalendar/service_auth_sub'
  require 'googlecalendar/calendar'
  
  def index
    # 消費税をチェックしたほうがよさそうな伝票
    @tax_check_count = TaxFinder.new(current_user).count

    # 未清算の仮負債
    @debts, @debt_sum = DebtFinder.new(current_user).list
    
    # みなし消費税の計算額と仕訳金額がずれているかチェック
    # 本締め後なのにずれている場合のみ警告
    fy = current_user.company.current_fiscal_year
    if fy.tax_management_type == TAX_MANAGEMENT_TYPE_DEEMED and not fy.is_open
      logic = DeemedTax::DeemedTaxLogic.new(fy)
      @dtm = logic.get_deemed_tax_model
    end
  end
  
  # Googleカレンダーからイベントを取得する
  def get_todo_events
    begin
      @events = get_events if current_user.has_google_account
    rescue Exception=>e
      handle(e)
    end
    
    render :partial=>'todo_events'
  end
  
private
  def get_events
    now = Time.now
    year_later = now + 60*60*24*31
    
    ret = []
    get_calendars.each_value do |c|
      c.events(:singleevents=>true,
          "start-min"=>now.strftime('%Y-%m-%dT00:00:00'),
          "start-max"=>year_later.strftime('%Y-%m-%dT00:00:00'),
          "recurrence-expansion-start"=>now.strftime('%Y-%m-%dT00:00:00'),
          "recurrence-expansion-end"=>year_later.strftime('%Y-%m-%dT00:00:00')).each do |e|
        ret << e
      end
    end
    ret.sort{|a,b| a.st <=> b.st}
  end

  def get_calendars
    GoogleCalendar::Calendar.calendars(google_service)
  end

  def google_service
    unless session[:google_service]
      session[:google_service] = GoogleCalendar::Service.new(current_user.google_account, current_user.google_password)
    end
    session[:google_service]
  end
end
