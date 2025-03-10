require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase

  def test_編集
    sign_in user
    get :edit, params: {id: user.id}
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    patch :update, params: {id: user.id, profile: profile_params}
    assert_response :redirect
    assert_redirected_to action: 'edit', id: user.id
  end

end
