require 'test_helper'

class Mm::RentsControllerTest < ActionController::TestCase

  def setup
    sign_in admin
  end

  def test_一覧
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:rents)
  end

  def test_一覧_取引先マスタが未登録
    Customer.delete_all

    get :index
    assert_response :success
    assert_template 'check_customer_exists'
  end

  def test_should_get_new
    get :new, :xhr => true
    assert_response :success
    assert_not_nil assigns(:rent)
  end

  def test_should_create_rent
    assert_difference 'Rent.count', 1 do
      post :create, :xhr => true, :params => {
        :rent => {
          :rent_type => "1", :usage_type => "1",
          :address => "住所", :customer_id => "1",
          :name => "表示名",
          status: "1", start_from: "2007-10-10"
        }
      }
    end

    assert_response :success
  end
  
  def test_should_create_rent_with_errors
    post :create, :xhr => true, :params => {
      :rent => {
        :rent_type => "", :usage_type => "",
        :address => "住所", :customer_id => "1",
        :name => "",
        status: "", start_from: "", end_to: "2009-01-0"
      }
    }
    
    assert_response :success
    assert_equal 5, assigns(:rent).errors.size
    assert_template 'new'
  end
  
  def test_should_get_edit
    get :edit, xhr: true, params: {id: rents(:rent_00005).id}
    assert_response :success
  end

  def test_should_update_rent
    patch :update, xhr: true, params: {id: rents(:rent_00005).id, format: 'js',
                              :rent => {:rent_type => "1", :usage_type => "1",
                                        :address => "住所", :customer_id => "1",
                                        :name => "表示名",
                              :status => "0" }}
    assert_response :success
    assert_template 'common/reload'
  end

  def test_should_destroy_rent
    assert_difference('Rent.count', -1) do
      delete :destroy, :params => {:id => rents(:rent_00005).id}
    end

    assert_redirected_to :action => 'index'
  end
end
