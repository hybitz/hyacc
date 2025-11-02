module HelperMethods

  def time_string(now = nil)
    now ||= Time.now
    '%s%03d' % [now.strftime('%Y%m%d%H%M%S'), (now.usec / 1000.0).round]
  end

end