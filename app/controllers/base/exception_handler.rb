# coding: UTF-8
#
# $id$
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Base::ExceptionHandler
  include HyaccErrors
  
  def handle(e, options={})
    if e.is_a? ActiveRecord::StaleObjectError
      message = ERR_STALE_OBJECT
      HyaccLogger.warn message, e
      store_error_message(message)
    elsif e.is_a? ActiveRecord::RecordInvalid
      HyaccLogger.info e.record.errors.full_messages
      message = e.record.errors.full_messages.join('<br/>'.html_safe)
      store_error_message(message)
    elsif e.is_a? GoogleCalendar::AuthenticationFailed
      message = 'Googleカレンダーにアクセスできません。認証に失敗しました。'
      HyaccLogger.warn message, e
      store_error_message(message)
    elsif e.is_a? HyaccException
      message = e.message
      HyaccLogger.warn message, e
      store_error_message(message)
    elsif e.is_a? SocketError
      handle_socket_error(e, options)
    else
      handle_error(e, options)
    end
  end

  private

  def handle_error(e, options={})
    HyaccLogger.error e.message, e
    raise e
  end

  def handle_socket_error(e, options={})
    if controller_name == 'notification' and action_name == 'get_todo_events'
      message = 'Googleカレンダーに接続できませんでした。'
      HyaccLogger.warn message,e if RAILS_ENV == 'production'
    else
      message = e
      HyaccLogger.error message, e
    end

    store_error_message(message)
  end
  
  def store_error_message(message)
    flash[:notice] = message
    flash[:is_error_message] = true
  end
end
