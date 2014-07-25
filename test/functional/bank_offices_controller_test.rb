require 'test_helper'

class BankOfficesControllerTest < ActionController::TestCase

  setup do
    sign_in users(:first)
  end
  
  def test_追加
    xhr :get, :add_bank_office
    assert_response :success
    assert_template :add_bank_office
  end

end
