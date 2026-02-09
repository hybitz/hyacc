require 'test_helper'

class Report::WithholdingSlipControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_should_get_details_list
    sign_in user
    get :index, :params => {:commit => true, :finder => details_finder}
    assert_response :success
    assert_template :withholding_details
  end

  def test_should_get_summary_list
    sign_in user
    get :index, :params => {:commit => true, :finder => summary_finder}
    assert_response :success
    assert_template :withholding_summary
  end
  
  def test_should_get_no_employee
    sign_in user
    get :index, :params => {:commit => true, :finder => no_employee_finder}
    assert_response :success
  end

  def test_源泉徴収票表示_所得税控除情報なし
    sign_in user
    get :index, :params => {:commit => true, :finder => no_exemption_details_finder}
    assert_response :success
    assert_template :no_exemption
  end
  
end
