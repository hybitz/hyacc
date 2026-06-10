require 'test_helper'

class Mm::BranchesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in admin
    get :index
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in admin
    get :show, :xhr => true, :params => {:id => branch.id}
    assert_response :success
    assert_template :show
  end

  def test_追加
    sign_in admin
    get :new, :xhr => true, :params => {:parent_id => branch.id}
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in admin
    post :create, :xhr => true, :params => {:branch => branch_params}
    assert @branch = assigns(:branch)
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in admin

    assert_no_difference 'Branch.count' do
      post :create, xhr: true, params: { branch: invalid_branch_params }
      assert_response :success
      assert_template :new
    end
  end

  def test_編集
    sign_in admin
    get :edit, :xhr => true, :params => {:id => branch.id}
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in admin
    patch :update, :xhr => true, :params => {:id => branch.id, :branch => branch_params.slice(:name)}
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in admin
    assert branch = Branch.find_by(company_id: 1, code: 102)

    patch :update, xhr: true, params: { id: branch.id, branch: invalid_branch_params.except(:code, :parent_id) }
    assert_response :success
    assert_template :edit
  end

  def test_削除
    sign_in admin
    assert branch = Branch.find_by(company_id: 1, code: 102)

    delete :destroy, xhr: true, params: { id: branch.id }
    assert_response :success
    assert_template 'common/reload'
    assert branch.reload.deleted?
  end

  def test_本店は削除できない
    sign_in admin
    assert head_office = Branch.find_by(company_id: 1, code: 101)

    exception = assert_raises(HyaccException) do
      delete :destroy, xhr: true, params: { id: head_office.id }
    end
    assert_equal HyaccErrors::ERR_BRANCH_HEAD_OFFICE, exception.message
  end

end
