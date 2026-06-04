require 'test_helper'

class MmControllerTest < ActionDispatch::IntegrationTest

  def test_index
    sign_in admin
    get mm_path
    assert_response :success
    assert_equal '/mm', path
  end

  def test_管理者以外は従業員マスタにアクセスできない
    sign_in user
    get mm_employees_path
    assert_response :forbidden
  end
end
