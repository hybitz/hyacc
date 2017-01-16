source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'

gem 'activerecord-session_store'
gem 'activerecord-import'
gem 'acts_as_tree'
gem 'carrierwave'
gem 'carrierwave-i18n'
gem 'coffee-rails', '~> 4.1.0'
gem 'colorable'
gem 'daddy'
gem 'dalli'
gem 'devise'
gem 'devise-i18n'
gem 'email_validator', '1.5.0'
gem 'fullcalendar-rails'
gem 'gcalapi'
gem 'i18n-js', '>= 3.0.0.rc11'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'materialize-sass'
gem 'mimemagic'
gem 'mini_magick'
gem 'momentjs-rails'
gem 'mousetrap-rails'
gem 'mysql2', '>= 0.3.13', '< 0.5'
gem 'nostalgic'
gem 'rails-csv-fixtures', :path => 'vendor/gems/rails-csv-fixtures'
gem 'rails-i18n'
gem 'remotipart'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'sinatra'
gem 'strong_actions'
gem 'tax_jp'
gem 'two_factor_authentication'
gem 'turbolinks', '< 3'
gem 'uglifier', '>= 1.3.0'
gem 'will_paginate'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'unicorn'

# Use Capistrano for deployment
group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'rubocop', :require => false
end

group :development do
  # Need to install Graphviz. 'sudo yum install graphviz'
  gem 'rails-erd'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'selenium-webdriver', '~> 2.53'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
end
