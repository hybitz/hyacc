require 'test_helper'

class Mm::QualificationsControllerTest < ActionDispatch::IntegrationTest

  def setup
    sign_in admin
  end

  def test_一覧
    get mm_qualifications_path
    assert_response :success
    assert_template 'index'
  end

  def test_新規
    get new_mm_qualification_path, xhr: true
    assert_response :success
    assert_template :new
  end

  def test_登録
    @expected = Qualification.new(name: 'テスト資格', allowance: '5000')

    post mm_qualifications_path, xhr: true, params: {
      qualification: @expected.attributes.slice('name', 'allowance')
    }
    assert_response :success
    assert_template 'common/reload'
    
    assert @actual = assigns(:qualification)
    assert_equal @expected.name, @actual.name
    assert_equal @expected.allowance, @actual.allowance
  end

  def test_登録_入力エラー
    assert_no_difference 'Qualification.count' do
      post mm_qualifications_path, xhr: true, params: {
        qualification: {name: '', allowance: ''}
      }
    end

    assert_response :success
    assert_template :new
    assert assigns(:qualification).errors[:name].present?
    assert assigns(:qualification).errors[:allowance].present?
  end

  def test_更新_入力エラー
    patch mm_qualification_path(qualification), xhr: true, params: {
      qualification: {name: '', allowance: ''}
    }

    assert_response :success
    assert_template :edit
    assert assigns(:qualification).errors[:name].present?
    assert assigns(:qualification).errors[:allowance].present?
  end
end
