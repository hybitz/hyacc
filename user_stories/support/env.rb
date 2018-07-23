require 'closer'

begin
  require 'cucumber/rails'
  Cucumber::Rails::Database.autorun_database_cleaner = false
rescue LoadError => e
  puts 'cucumber-rails not found.'
end

require 'daddy/cucumber'

include HyaccConstants

Dir[File.join(Rails.root, 'features', 'support', '*_support.rb')].each do |f|
  require f
end

Before do |scenario|
  resize_window(1280, 720)
end
