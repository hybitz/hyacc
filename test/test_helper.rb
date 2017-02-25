require 'daddy/test_help'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include HyaccConstants
  include HyaccErrors

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each do |f|
    require f
    include File.basename(f).split('.').first.camelize.constantize
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers

  protected

  def sign_in(user)
    super(user)
    @_current_user = user
  end

  def current_user
    @_current_user
  end

  def upload_file(filename)
    path = File.join('test', 'upload_files', filename)
    Rack::Test::UploadedFile.new(path, MimeMagic.by_path(path).to_s)
  end

end

class ActionDispatch::IntegrationTest

  def sign_in(user)
    post user_session_path, :params => {:user => {:login_id => user.login_id, :password => 'testtest'}}
    assert_response :redirect
    assert_redirected_to root_path
  end

end
