require 'test_helper'

class SimpleSlipController::DepositTest < ActionController::TestCase
  include HyaccUtil
  
  setup do
    sign_in user
  end

  def test_create
    assert_difference 'JournalHeader.count' do
      post :create,
        :account_code=>ACCOUNT_CODE_ORDINARY_DIPOSIT,
        :slip => {
          "my_sub_account_id"=>"1",
          "ym"=>"200712",
          "remarks"=>"a",
          "branch_id"=>"2",
          "account_id"=>"2",
          "id"=>"",
          "day"=>"07",
          "amount_increase"=>"10000",
          :tax_type => TAX_TYPE_NONTAXABLE}
    end

    assert_response :redirect
    assert_redirected_to :action=>:index
  end
  
  def test_index
    get :index,
      :account_code=>ACCOUNT_CODE_ORDINARY_DIPOSIT,
      :branch_id=>nil

    assert_response :success
  end

  def test_file_upload
    num_journal_headers = JournalHeader.count
    
    assert_difference 'JournalHeader.count', 1 do
      post :create,
        :account_code=>ACCOUNT_CODE_ORDINARY_DIPOSIT,
        :slip => {
          "my_sub_account_id"=>"1",
          "ym"=>"200712",
          "remarks"=>"アップロードテスト",
          "branch_id"=>"2",
          "account_id"=>"2",
          "id"=>"",
          "day"=>"07",
          "amount_increase"=>"5000",
          :tax_type => TAX_TYPE_NONTAXABLE,
          "receipt_file" => upload_file('README')}
    end
    
    # 領収書ファイルアップロードのテスト
    assert_response :redirect
    assert_redirected_to :action => 'index'
    
    list = JournalHeader.where(:remarks => 'アップロードテスト')
    assert_equal 1, list.count
    assert jh = list.first
    assert_equal "README", File::basename(jh.receipt_path)
    
    # アップロードファイルを削除
    delete_upload_file(jh.receipt_path)
  end


  def test_預金で銀行口座の指定がない場合に更新処理がエラーになること
    post :update, :format => 'js',
      :account_code=>ACCOUNT_CODE_ORDINARY_DIPOSIT,
      :slip => {
        "id"=>9,
        "my_sub_account_id"=>"",
        "ym"=>200712,
        "day"=>7,
        "remarks"=>"a",
        "branch_id"=>"2",
        "account_id"=>"2",
        "amount_increase"=>10000,
        :tax_type => TAX_TYPE_NONTAXABLE}

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:slip)
    assert_not_nil assigns(:slip).errors
    assert_not_nil assigns(:slip).journal_header.journal_details[0].errors[:sub_account]
  end

  def test_預金で銀行口座の指定がない場合に登録処理がエラーになること
    post :create,
      :account_code=>ACCOUNT_CODE_ORDINARY_DIPOSIT,
      :slip => {
        "my_sub_account_id"=>"",
        "ym"=>"200805",
        "remarks"=>"a",
        "branch_id"=>"2",
        "account_id"=>"2",
        "id"=>"",
        "day"=>"07",
        "amount_increase"=>"10000",
        :tax_type => TAX_TYPE_NONTAXABLE}

    assert_response :success
    assert_template :index
    assert_not_nil assigns(:slip)
    assert_not_nil assigns(:slip).errors
    assert_not_nil assigns(:slip).journal_header.journal_details[0].errors[:sub_account]
  end

end
