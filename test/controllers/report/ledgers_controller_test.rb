require 'test_helper'

class Report::LedgersControllerTest < ActionDispatch::IntegrationTest

  def test_一覧
    sign_in user
    get report_ledgers_path
    assert_response :success
    assert_template :index
  end

end
