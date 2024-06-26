require 'test_helper'

class Mm::ExemptionsControllerTest < ActionController::TestCase

  setup do
    @employee_id = 6
    @exemption = exemptions(35)
  end
  
  def test_初期表示
    sign_in admin
    get :index
    assert_response :success
    assert_template :index
  end

  def test_追加
    sign_in admin
    get :new, :params => {:exemption => valid_exemption_params}, :xhr => true
    assert_response :success
    assert_template :new
  end
  
  def test_追加_employee_id
    sign_in admin
    get :new, :params => {:exemption => { employee_id: @employee_id }}, :xhr => true

    assert_response :success

    d = assigns(:d)
    assert_not_nil d
    assert_equal 35, d.id
    assert_equal 2012, d.yyyy
    assert_equal @employee_id, d.employee_id
    assert_not_nil assigns(:c)
    assert assigns(:c).is_a?(Exemption)

    dependent_family_members = assigns(:c).dependent_family_members.select { |dfm| dfm.exemption_type == EXEMPTION_TYPE_UNDER_16 }
    assert_not_empty dependent_family_members, "Under 16 family members should not be empty"
    dependent_family_members.each do |member|
      assert_equal "営業　次郎", member.name
      assert_equal "ジロウ　エイギョウ", member.kana
      assert_equal "123456789012", member.my_number
    end
  end
  
  def test_登録
    sign_in admin
    post :create, :params => {:exemption => valid_exemption_params}, :xhr => true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_編集
    sign_in admin
    get :edit, :params => {:id => @exemption.id}, :xhr => true
    assert_response :success
    assert_not_nil assigns(:c)
    assert assigns(:c).is_a?(Exemption)
    under16_members = assigns(:c).dependent_family_members.select { |dfm| dfm.exemption_type == EXEMPTION_TYPE_UNDER_16 }
    assert_not_empty under16_members, "Under 16 family members should not be empty"
    assert_template :edit
  end

  def test_更新
    sign_in admin
    patch :update, :params => {:id => exemption.id, :exemption => valid_exemption_params}, :xhr => true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_削除
    sign_in admin
    delete :destroy, :params => {:id => exemption.id}
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
