require 'test_helper'

class SimpleSlipsController::CashTest < ActionController::TestCase

  def setup
    sign_in user
  end

  # 子を持つ勘定科目が指定できないことを確認
  def test_create_fail_by_node_account
    post :create,
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "ym"=>"200712",
        "remarks"=>"仕訳登録不可の勘定科目を指定できないこと",
        "branch_id"=>"2",
        "account_id"=>Account.find_by_code(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE).id,
        "amount_decrease"=>"1000",
        "id"=>"",
        "day"=>"25"}

    assert_response :success
    assert_template :index
    assert_not_nil flash[:notice]
    assert flash[:is_error_message]
    assert_not_nil assigns(:slip)
    assert_not_nil assigns(:slip).journal_details[1].errors[:account]
  end

  # 摘要の入力がない場合はエラー
  def test_create_fail_by_remarks
    post :create,
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "ym"=>"200712",
        "remarks"=>"",
        "branch_id"=>"2",
        "account_id"=>Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id,
        "amount_decrease"=>"1000",
        "id"=>"",
        "day"=>"01"}

    assert_response :success
    assert_template :index
    assert_not_nil assigns(:slip).errors[:remarks]
  end

  # 同一科目の指定の場合はエラー
  # 通常の画面上からは入力できないがサーバーではチェックをする
  def test_edit_fail_by_same_account
    post :create,
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "ym"=>"200711",
        "remarks"=>"あああ",
        "branch_id"=>"2",
        "account_id"=>Account.find_by_code(ACCOUNT_CODE_CASH).id,
        "amount_decrease"=>"1000",
        "id"=>"",
        "day"=>"01"}

    assert_response :success
    assert_template :index
    assert_equal ERR_INVALID_SLIP, flash[:notice]
  end

  # 楽観的ロックによる更新エラー
  def test_edit_fail_by_lock
    jh = JournalHeader.find(10)

    xhr :patch, :update, :id => jh.id,
      :account_code => ACCOUNT_CODE_CASH,
      :slip => {
        "my_sub_account_id"=>"",
        "ym"=>200905,
        "day"=>17,
        "remarks"=>"タクシー代",
        "branch_id"=>2,
        "account_id"=>21,
        "tax_type"=>"2",
        "amount_increase"=>1130,
        "tax_amount_increase"=>53,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "lock_version"=>jh.lock_version
      }

    assert_response :success
    assert_template 'common/reload'
    assert_not_nil assigns(:slip)

    xhr :patch, :update, :id => jh.id,
      :account_code => ACCOUNT_CODE_CASH,
      :slip => {
        "my_sub_account_id"=>"",
        "ym"=>200905,
        "day"=>17,
        "remarks"=>"タクシー代",
        "branch_id"=>2,
        "account_id"=>21,
        "amount_increase"=>1130,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "lock_version"=>jh.lock_version
      }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:slip)
    assert assigns(:slip).errors.empty?
  end

  # 楽観的ロックによる削除エラー
  def test_destroy_fail_by_lock
    xhr :patch, :update, :id => 10,
      :account_code => ACCOUNT_CODE_CASH,
      :slip => {
        "my_sub_account_id"=>"",
        "ym"=>200905,
        "day"=>17,
        "remarks"=>"タクシー代",
        "branch_id"=>2,
        "account_id"=>21,
        "tax_type"=>TAX_TYPE_NONTAXABLE,
        "amount_increase"=>1130,
        "lock_version"=>0
      }

    assert_response :success
    assert_template 'common/reload'
    assert_not_nil assigns(:slip)

    post :destroy,
      :account_code => ACCOUNT_CODE_CASH,
      :id => 10,
      :lock_version => 0

    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_not_nil JournalHeader.find(10)
  end
end
