require 'test_helper'

class Mm::DonationRecipientsControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in admin
  end

  def test_一覧
    get mm_donation_recipients_path
    assert_response :success
    assert_template 'index'
  end

  def test_参照
    dr = donation_recipients(:one)
    get mm_donation_recipient_path(dr), xhr: true
    assert_response :success
    assert_template :show
  end

  def test_新規フォーム
    get new_mm_donation_recipient_path, xhr: true
    assert_response :success
    assert_template :new
  end

  def test_編集フォーム
    dr = donation_recipients(:one)
    get edit_mm_donation_recipient_path(dr), xhr: true
    assert_response :success
    assert_template :edit
  end

  def test_登録
    post mm_donation_recipients_path, xhr: true, params: {
      donation_recipient: {
        kind: SUB_ACCOUNT_CODE_DONATION_DESIGNATED,
        name: 'テスト寄付先',
        announcement_number: '1-2-3',
        purpose: '教育'
      }
    }
    assert_response :success
    assert_template 'common/reload'

    dr = assigns(:donation_recipient)
    assert dr.persisted?
    assert_equal SUB_ACCOUNT_CODE_DONATION_DESIGNATED, dr.kind
    assert_equal 'テスト寄付先', dr.name
  end

  def test_特定公益増進で所在地が保存される
    post mm_donation_recipients_path, xhr: true, params: {
      donation_recipient: {
        kind: SUB_ACCOUNT_CODE_DONATION_PUBLIC_INTEREST,
        name: '特定公益増進テスト',
        address: '東京都千代田区1-2-3',
        purpose_or_name: '使途又は名称'
      }
    }
    assert_response :success
    dr = assigns(:donation_recipient)
    assert dr.persisted?
    assert_equal SUB_ACCOUNT_CODE_DONATION_PUBLIC_INTEREST, dr.kind
    assert_equal '東京都千代田区1-2-3', dr.address
    assert_equal '使途又は名称', dr.purpose_or_name
  end

  def test_非認定信託で信託名と所在地が保存される
    post mm_donation_recipients_path, xhr: true, params: {
      donation_recipient: {
        kind: SUB_ACCOUNT_CODE_DONATION_NON_CERTIFIED_TRUST,
        name: '非認定信託テスト',
        address: '大阪府大阪市1-2-3',
        trust_name: 'テスト信託'
      }
    }
    assert_response :success
    dr = assigns(:donation_recipient)
    assert dr.persisted?
    assert_equal SUB_ACCOUNT_CODE_DONATION_NON_CERTIFIED_TRUST, dr.kind
    assert_equal '大阪府大阪市1-2-3', dr.address
    assert_equal 'テスト信託', dr.trust_name
  end

  def test_登録_入力エラー
    assert_no_difference 'DonationRecipient.count' do
      post mm_donation_recipients_path, xhr: true, params: {
        donation_recipient: { kind: SUB_ACCOUNT_CODE_DONATION_DESIGNATED, name: '', announcement_number: '1-2-3', purpose: '教育' }
      }
    end
    assert_response :success
    assert_template :new
    assert assigns(:donation_recipient).errors[:name].present?
  end

  def test_更新
    dr = donation_recipients(:one)
    patch mm_donation_recipient_path(dr), xhr: true, params: {
      donation_recipient: {
        kind: dr.kind,
        name: '更新後の名称',
        announcement_number: dr.announcement_number,
        purpose: dr.purpose,
        address: dr.address,
        purpose_or_name: dr.purpose_or_name,
        trust_name: dr.trust_name
      }
    }
    assert_response :success
    assert_template 'common/reload'
    assert_equal '更新後の名称', dr.reload.name
  end

  def test_更新_入力エラー
    dr = donation_recipients(:one)
    patch mm_donation_recipient_path(dr), xhr: true, params: {
      donation_recipient: {
        kind: dr.kind,
        name: '',
        announcement_number: dr.announcement_number,
        purpose: dr.purpose,
        address: dr.address,
        purpose_or_name: dr.purpose_or_name,
        trust_name: dr.trust_name
      }
    }
    assert_response :success
    assert_template :edit
    assert assigns(:donation_recipient).errors[:name].present?
    assert_equal 'テスト寄付先', dr.reload.name
  end

  def test_紐づきありのときは種別を変更できない
    dr = donation_recipients(:one)

    patch mm_donation_recipient_path(dr), xhr: true, params: {
      donation_recipient: {
        kind: SUB_ACCOUNT_CODE_DONATION_PUBLIC_INTEREST,
        name: dr.name,
        announcement_number: dr.announcement_number,
        purpose: dr.purpose,
        address: dr.address,
        purpose_or_name: dr.purpose_or_name,
        trust_name: dr.trust_name
      }
    }
    assert_response :success
    assert_template 'common/reload'
    assert_equal SUB_ACCOUNT_CODE_DONATION_DESIGNATED, dr.reload.kind
  end

  def test_削除は論理削除
    dr = donation_recipients(:for_deletion)
    delete mm_donation_recipient_path(dr)
    assert_redirected_to action: 'index'
    assert dr.reload.deleted?
  end

  def test_紐づいているときは削除できない
    dr = donation_recipients(:one)

    delete mm_donation_recipient_path(dr)
    assert_redirected_to action: 'index'
    assert_not dr.reload.deleted?
    assert flash[:is_error_message]
    assert_equal ERR_DONATION_RECIPIENT_LINKED, flash[:notice]
  end
end
