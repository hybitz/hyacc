require 'test_helper'

class BanksControllerTest < ActionController::TestCase

  setup do
    @request.session[:user_id] = users(:first).id
  end
  
  def test_index
    get :index, :commit => '表示'
    assert_response :success
    assert_not_nil assigns(:banks)
  end

  def test_new
    xhr :get, :new
    assert_response :success
    assert_template :new
  end

  def test_create
    assert_difference('Bank.count') do
      xhr :post, :create,
          :bank => {:name => '三井住友銀行',
                    :code => '0009',
                    :deleted => false}
    end

    assert_response :success
  end

  def test_show
    xhr :get, :show, :id => banks(:data1).id
    assert_response :success
  end

  def test_edit
    xhr :get, :edit, :id => banks(:data1).id
    assert_response :success
    assert_template :edit
  end

  def test_update
    xhr :put, :update, :id => banks(:data1).id, :bank => { }
    assert_response :success
  end

  def test_destroy
    assert_no_difference 'Bank.count' do
      delete :destroy, :id => banks(:data1).id
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
  end
end
