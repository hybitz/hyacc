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
    elsif e.is_a? HyaccException
      message = e.message
      HyaccLogger.warn message, e
      store_error_message(message)
    else
      handle_error(e, options)
    end
  end

  private

  def handle_error(e, options={})
    HyaccLogger.error e.message, e
    raise e
  end

  def store_error_message(message)
    flash[:notice] = message
    flash[:is_error_message] = true
  end
end
