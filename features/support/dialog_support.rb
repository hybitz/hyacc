module DialogSupport

  def has_dialog?(options = {})
    options = {title: options} if options.is_a?(String) || options.is_a?(Regexp)

    assert wait_until { has_selector?("div.ui-dialog", visible: true) }

    if options[:title]
      assert_selector("span.ui-dialog-title", text: options[:title])
    end

    true
  end

  def has_no_dialog?(options = {})
    options = {title: options} if options.is_a?(String) || options.is_a?(Regexp)

    assert wait_until {
      begin
        has_no_selector?("div.ui-dialog")
      rescue Selenium::WebDriver::Error::UnknownError,
             Selenium::WebDriver::Error::StaleElementReferenceError => e
        false
      end
    }

    if options[:title]
      assert_no_selector("span.ui-dialog-title", text: options[:title])
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