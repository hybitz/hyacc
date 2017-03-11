source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'

gem 'activerecord-session_store'
gem 'activerecord-import'
gem 'acts_as_tree'
gem 'carrierwave'
gem 'carrierwave-i18n'
gem 'coffee-rails', '~> 4.2'
gem 'colorable'
gem 'daddy'
gem 'devise'
gem 'devise-i18n'
gem 'email_validator', '1.5.0'
gem 'fullcalendar-rails'
gem 'i18n-js', '>= 3.0.0.rc11'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'materialize-sass'
gem 'mimemagic'
gem 'mini_magick'
gem 'momentjs-rails'
gem 'mousetrap-rails'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'nostalgic'
gem 'puma', '~> 3.0'
gem 'rails-controller-testing'
gem 'rails-i18n'
gem 'remotipart'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'strong_actions'
gem 'tax_jp'
gem 'turbolinks', '~> 5'
gem 'two_factor_authentication'
gem 'uglifier', '>= 1.3.0'
gem 'unicorn'
gem 'will_paginate'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
  gem 'listen', '~> 3.0.5'
  gem 'rails-erd'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner', :require => false
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'selenium-webdriver', '~> 2.53'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
end
