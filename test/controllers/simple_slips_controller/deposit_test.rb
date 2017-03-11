require 'test_helper'

class SimpleSlipsController::DepositTest < ActionController::TestCase

  def setup
    sign_in user
  end

  def test_登録
    assert_difference 'JournalHeader.count', 1 do
      post :create, :params => {
        :account_code => ACCOUNT_CODE_ORDINARY_DIPOSIT,
        :simple_slip => {
          "my_sub_account_id"=>"1",
          "ym"=>"200712",
          "remarks"=>"a",
          "branch_id"=>"2",
          "account_id"=>"2",
          "day"=>"07",
          "amount_increase"=>"10000",
          :tax_type => TAX_TYPE_NONTAXABLE}
      }
    end

    assert_response :redirect
    assert_redirected_to :action => :index
  end

  def test_index
    get :index, :params => {:account_code => ACCOUNT_CODE_ORDINARY_DIPOSIT}
    assert_response :success
    assert_template :index
  end

  def test_預金で銀行口座の指定がない場合に更新処理がエラーになること
    assert_no_difference 'JournalHeader.count' do
      patch :update, :xhr => true, :params => {:id => 9,
        :account_code => ACCOUNT_CODE_ORDINARY_DIPOSIT,
        :simple_slip => {
          "my_sub_account_id"=>"",
          "ym"=>200712,
          "day"=>7,
          "remarks"=>"a",
          "branch_id"=>"2",
          "account_id"=>"2",
          "amount_increase"=>10000,
          :tax_type => TAX_TYPE_NONTAXABLE}
      }
    end

    assert_response :success
    assert_template 'edit'
    assert simple_slip = assigns(:simple_slip)
    assert simple_slip.errors[:my_sub_account].any?
  end

  def test_預金で銀行口座の指定がない場合に登録処理がエラーになること
    assert_no_difference 'JournalHeader.count' do
      post :create, :params => {
        :account_code => ACCOUNT_CODE_ORDINARY_DIPOSIT,
        :simple_slip => {
          "my_sub_account_id"=>"",
          "ym"=>"200805",
          "remarks"=>"a",
          "branch_id"=>"2",
          "account_id"=>"2",
          "day"=>"07",
          "amount_increase"=>"10000",
          :tax_type => TAX_TYPE_NONTAXABLE}
      }
    end

    assert_response :success
    assert_template :index
    assert simple_slip = assigns(:simple_slip)
    assert simple_slip.errors[:my_sub_account].any?
  end

end
