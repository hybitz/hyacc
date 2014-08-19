require 'test_helper'

class WithheldTaxesControllerTest < ActionController::TestCase

  setup do
    sign_in users(:first)
  end

  def test_upload_success
    post :upload,:file => upload_file('withheld_tax.csv')
    assert_redirected_to :action => "index"
    assert_equal 3,assigns(:list).size
  end
  
  def test_一覧
    get :index
    assert_response :success
    assert_template :index
  end

  def test_should_get_new
    get :new
    assert_response :success
    assert_template :new
  end

  def test_should_create_withheld_tax
    assert_difference 'WithheldTax.count' do
      post :create, :withheld_tax => {:apply_start_ym => 200902,
                                      :apply_end_ym => 200909,
                                      :pay_range_above => 370000,
                                      :pay_range_under => 395000,
                                      :no_dependent => 8150,
                                      :one_dependent => 7150,
                                      :two_dependent => 6150,
                                      :three_dependent => 5150,
                                      :four_dependent => 4150,
                                      :five_dependent => 3150,
                                      :six_dependent => 2000,
                                      :seven_dependent => 0}
    end
    assert_redirected_to withheld_taxes_path
  end

  def test_should_show_withheld_tax
    get :show, :id => withheld_taxes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => withheld_taxes(:one).id, :format => 'js'
    assert_response :success
    assert_template :edit
  end

  def test_更新
    xhr :patch, :update, :id => withheld_taxes(:one).id,
        :withheld_tax => {
          :apply_start_ym => 200902,
          :apply_end_ym => 200909,
          :pay_range_above => 370000,
          :pay_range_under => 395000,
          :no_dependent => 8150,
          :one_dependent => 7150,
          :two_dependent => 6150,
          :three_dependent => 5150,
          :four_dependent => 4150,
          :five_dependent => 3150,
          :six_dependent => 2000,
          :seven_dependent => 0
        }
    
    assert_response :success
    assert_template '_line'
  end

  def test_削除
    assert_difference 'WithheldTax.count', -1 do
      delete :destroy, :id => withheld_taxes(:one).id
    end
    
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end
end
