module AssertionMethods
  
  def has_notice?
    has_selector?('.notice ul li', :minimum => 1)
  end

end

World(AssertionMethods)
