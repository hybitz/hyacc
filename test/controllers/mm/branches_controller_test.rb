require 'test_helper'

class Mm::BranchesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in user
    xhr :get, :show, :id => branch.id
    assert_response :success
    assert_template :show
  end

  def test_追加
    sign_in user
    xhr :get, :new, :parent_id => branch.id
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in user
    xhr :post, :create, :branch => valid_branch_params
    assert @branch = assigns(:branch)
    assert_response :success
    assert_template 'common/reload'
  end

  def test_編集
    sign_in user
    xhr :get, :edit, :id => branch.id
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    xhr :patch, :update, :id => branch.id, :branch => valid_branch_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_削除
    sign_in user
    xhr :delete, :destroy, :id => branch.id
    assert_response :success
    assert_template 'common/reload'
  end

end
