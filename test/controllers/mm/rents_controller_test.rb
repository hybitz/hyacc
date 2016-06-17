require 'test_helper'

class Mm::RentsControllerTest < ActionController::TestCase

  def setup
    sign_in user
  end
  
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:rents)
  end

  def test_should_get_new
    xhr :get, :new
    assert_response :success
    assert_not_nil assigns(:rent)
  end

  def test_should_create_rent
    assert_difference 'Rent.count', 1 do
      xhr :post, :create,
          :rent => {:rent_type => "1", :usage_type => "1",
                    :address => "住所", :customer_id => "1",
                    :name => "表示名",
                    :status => "1", :ymd_start => "20071010" }
    end

    assert_response :success
  end
  
  def test_should_create_rent_with_errors
    xhr :post, :create,
        :rent => {:rent_type => "", :usage_type => "",
                  :address => "住所", :customer_id => "1",
                  :name => "",
                  :status => "", :ymd_start => "", :ymd_end => "2009010" }
    
    assert_response :success
    assert_equal 6, assigns(:rent).errors.size
    assert_template 'new'
  end
  
  def test_should_get_edit
    xhr :get, :edit, :id => rents(:rent_00005).id
    assert_response :success
  end

  def test_should_update_rent
    put :update, :id => rents(:rent_00005).id, :format => 'js',
                              :rent => {:rent_type => "1", :usage_type => "1",
                                        :address => "住所", :customer_id => "1",
                                        :name => "表示名",
                                        :status => "0" }
    assert_response :success
    assert_template 'common/reload'
  end

  def test_should_destroy_rent
    assert_difference('Rent.count', -1) do
      delete :destroy, :id => rents(:rent_00005).id
    end

    assert_redirected_to :action => 'index'
  end
end
