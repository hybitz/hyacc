require 'test_helper'

class SimpleSlipTemplatesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_追加
    sign_in user
    get :new, :format => 'js'
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:simple_slip_template)
  end

  def test_登録
    sign_in user
    post :create, :format => 'js', :simple_slip_template => valid_simple_slip_template_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    post :create, :format => 'js', :simple_slip_template => invalid_simple_slip_template_params
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in user
    get :edit, :id => simple_slip_template.id, :format => 'js'
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:simple_slip_template)
  end

  def test_更新
    sign_in user
    put :update, :id => simple_slip_template.id, :format => 'js', :simple_slip_template => valid_simple_slip_template_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    put :update, :id => simple_slip_template.id, :format => 'js', :simple_slip_template => invalid_simple_slip_template_params
    assert_response :success
    assert_template 'edit'
  end

  def test_削除
    sign_in user
    delete :destroy, :id => simple_slip_template.id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
