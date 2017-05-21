require 'daddy/cucumber/rails'

include HyaccConstants

Dir[File.join(Rails.root, 'test', 'support', '*.rb')].each do |f|
  require f
  include File.basename(f).split('.').first.camelize.constantize
end

if ENV['CI'] == 'travis'
  caps = Selenium::WebDriver::Remote::Capabilities.chrome(
    'tunnel-identifier' => ENV['TRAVIS_JOB_NUMBER']
  )

  Capybara.default_driver = :selenium
  Capybara.register_driver :selenium do |app|
    driver = Capybara::Selenium::Driver.new(app,
      :browser => :remote,
      :url => "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com/wd/hub",
      :desired_capabilities => caps
    )
    driver.browser.file_detector = lambda do |args|
      str = args.first.to_s
      str if File.exist?(str)
    end
    
    driver
  end
end
