require 'cucumber/rails'
require 'daddy'
require 'daddy/cucumber/helpers'

require 'capybara/rails'
ActionController::Base.allow_rescue = false

require 'capybara/cucumber'
require 'capybara/webkit' if ENV['DRIVER'] == 'webkit'
require 'capybara/poltergeist' if ENV['DRIVER'] == 'poltergeist'

Capybara.default_driver = (ENV['DRIVER'] || :selenium).to_sym
Capybara.default_selector = :css

include HyaccConstants

system('rake db:seed')

Before do
  resize_window(1280, 720)
end

After do |scenario|
  Cucumber.wants_to_quit = true if scenario.failed?
end
