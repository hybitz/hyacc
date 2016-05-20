module DialogSupport

  def has_dialog?(options = {})
    options = {:title => options} if options.is_a?(String) or options.is_a?(Regexp)

    if options[:title]
      has_selector?("span.ui-dialog-title", :text => options[:title])
    end

    true
  end

  def has_no_dialog?(options = {})
    options = {:title => options} if options.is_a?(String) or options.is_a?(Regexp)

    if options[:title]
      has_no_selector?("span.ui-dialog-title", :text => options[:title])
    end

    true
  end

  def within_dialog(options = {})
    assert has_dialog?(options)
    within '.ui-dialog' do
      yield if block_given?
    end
  end

end

World(DialogSupport)