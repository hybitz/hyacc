source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'

gem 'activerecord-session_store'
gem 'activerecord-import'
gem 'acts_as_tree'
gem 'carrierwave'
gem 'carrierwave-i18n'
gem 'coffee-rails', '~> 4.2'
gem 'daddy'
gem 'dalli'
gem 'devise'
gem 'devise-i18n'
gem 'email_validator', '1.5.0'
gem 'faraday', '< 0.13.0'
gem 'fog-aws'
gem 'fullcalendar-rails'
gem 'i18n-js'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'mimemagic'
gem 'mini_magick'
gem 'momentjs-rails'
gem 'mousetrap-rails'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'nostalgic'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'puma', '~> 3.7'
gem 'rails-i18n'
gem 'redis', '~> 3.0'
gem 'remotipart'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'strong_actions'
gem 'tax_jp'
gem 'turbolinks', '~> 5'
gem 'two_factor_authentication'
gem 'uglifier', '>= 1.3.0'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary-edge'
gem 'will_paginate'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rails-erd'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'closer'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner', :require => false
  gem 'minitest','~> 5.10.3'
  gem 'minitest-reporters'
  gem 'rails-controller-testing'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
end
