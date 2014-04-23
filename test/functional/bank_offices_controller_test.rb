require 'test_helper'

class BankOfficesControllerTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:first).id
  end
  
end
