# coding: UTF-8

if ENV["COVERAGE"]
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start 'rails' 
end

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails"

class ActiveSupport::TestCase
  include HyaccConstants
  include HyaccErrors

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |f|
    self.class_eval File.read(f)
  end

end

class ActionController::TestCase

  protected

  def upload_file(filename, content_type='text')
    path = File.new("#{Rails.root}/test/upload_files/#{filename}")

    ActionDispatch::Http::UploadedFile.new(
      :filename => filename,
      :content_type => content_type,
      :tempfile => path
    )
  end

end
