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

    ActionDispatch::Http::UploadedFile.new(
      :filename => filename,
      :content_type => MimeMagic.by_path(path).to_s,
      :tempfile => File.new(path)
    )
  end

end
