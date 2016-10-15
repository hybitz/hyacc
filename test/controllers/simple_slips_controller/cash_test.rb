require 'test_helper'

class SimpleSlipsController::CashTest < ActionController::TestCase

  def setup
    sign_in user
  end

  # 子を持つ勘定科目が指定できないことを確認
  def test_create_fail_by_node_account
    post :create,
      :account_code=>ACCOUNT_CODE_CASH,
      :simple_slip => {
        "ym"=>"200712",
        "remarks"=>"仕訳登録不可の勘定科目を指定できないこと",
        "branch_id"=>"2",
        "account_id"=>Account.find_by_code(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE).id,
        "amount_decrease"=>"1000",
        "day"=>"25"}

    assert_response :success
    assert_template :index
    assert_not_nil flash[:notice]
    assert flash[:is_error_message]
    assert_not_nil assigns(:simple_slip)
    assert_not_nil assigns(:simple_slip).errors[:account]
  end

  # 摘要の入力がない場合はエラー
  def test_create_fail_by_remarks
    post :create,
      :account_code=>ACCOUNT_CODE_CASH,
      :simple_slip => {
        "ym"=>"200712",
        "remarks"=>"",
        "branch_id"=>"2",
        "account_id"=>Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id,
        "amount_decrease"=>"1000",
        "day"=>"01"}

    assert_response :success
    assert_template :index
    assert_not_nil assigns(:simple_slip).errors[:remarks]
  end

  # 同一科目の指定の場合はエラー
  # 通常の画面上からは入力できないがサーバサイドでチェックする
  def test_edit_fail_by_same_account
    assert_no_difference 'JournalHeader.count' do
      post :create,
        :account_code => ACCOUNT_CODE_CASH,
        :simple_slip => {
          "ym" => "200905",
          'day' => '01',
          "remarks" => "あああ",
          "branch_id" => "2",
          "account_id" => Account.find_by_code(ACCOUNT_CODE_CASH).id,
          "amount_decrease" => "1000",
          :tax_type => TAX_TYPE_NONTAXABLE
         }
    end

    assert_response :success
    assert_template :index
    assert slip = assigns(:simple_slip)
    assert_equal I18n.t('errors.messages.accounts_duplicated'), slip.errors[:base].first
  end

  # 楽観的ロックによる更新エラー
  def test_edit_fail_by_lock
    jh = JournalHeader.find(10)

    assert_no_difference 'JournalHeader.count' do
      xhr :patch, :update, :id => jh.id,
        :account_code => ACCOUNT_CODE_SMALL_CASH,
        :simple_slip => {
          "my_sub_account_id"=>"",
          "ym"=>200905,
          "day"=>17,
          "remarks"=>"タクシー代",
          "branch_id"=>2,
          "account_id"=>21,
          :amount_decrease => 1050,
          :tax_type => TAX_TYPE_INCLUSIVE,
          :tax_rate_percent => 5,
          :tax_amount_decrease => 50,
          :lock_version => jh.lock_version
        }
    end

    assert_response :success
    assert_template 'common/reload'
    assert assigns(:simple_slip)

    assert_no_difference 'JournalHeader.count' do
      xhr :patch, :update, :id => jh.id,
        :account_code => ACCOUNT_CODE_SMALL_CASH,
        :simple_slip => {
          "my_sub_account_id"=>"",
          "ym"=>200905,
          "day"=>17,
          "remarks"=>"タクシー代",
          "branch_id"=>2,
          "account_id"=>21,
          "amount_increase"=>1130,
          :tax_type => TAX_TYPE_NONTAXABLE,
          :tax_rate_percent => 0,
          "lock_version"=>jh.lock_version
        }
    end

    assert_response :success
    assert_template 'edit'
    assert assigns(:simple_slip)
    assert assigns(:simple_slip).errors.empty?
    assert_equal ERR_STALE_OBJECT, flash[:notice]
  end

  # 楽観的ロックによる削除エラー
  def test_destroy_fail_by_lock
    xhr :patch, :update, :id => 10,
      :account_code => ACCOUNT_CODE_SMALL_CASH,
      :simple_slip => {
        "my_sub_account_id"=>"",
        "ym"=>200905,
        "day"=>17,
        "remarks"=>"タクシー代",
        "branch_id"=>2,
        "account_id"=>21,
        "tax_type"=>TAX_TYPE_NONTAXABLE,
        :tax_rate_percent => 0,
        "amount_increase"=>1130,
        "lock_version"=>0
      }

    assert_response :success
    assert_template 'common/reload'
    assert assigns(:simple_slip)

    assert_no_difference 'JournalHeader.count' do
      post :destroy, :id => 10,
        :account_code => ACCOUNT_CODE_SMALL_CASH,
        :lock_version => 0
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert JournalHeader.where(:id => 10).present?
  end
end
