module HelperMethods
  
  def current_time_string
    Daddy::Utils::StringUtils::current_time
  end

end

World(HelperMethods)
