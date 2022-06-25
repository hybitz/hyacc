require 'test_helper'

class Hr::SocialInsurancesControllerTest < ActionDispatch::IntegrationTest

  def test_index
    sign_in admin
    get hr_social_insurances_path
    assert_response :success
    assert_template :index
  end

  def test_管理者のみアクセス可
    sign_in user
    get hr_social_insurances_path
    assert_response :forbidden
  end

end
