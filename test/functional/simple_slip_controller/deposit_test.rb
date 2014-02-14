# coding: UTF-8
#
# $Id: deposit_test.rb 3367 2014-02-07 15:05:22Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class SimpleSlipController::DepositTest < ActionController::TestCase
  include HyaccUtil
  
  def setup
    @request.session[:user_id] = users(:first).id
  end

  def test_create
    num_journal_headers = JournalHeader.count

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

    assert_response :redirect
    assert_redirected_to :action=>:index

    assert_equal num_journal_headers + 1, JournalHeader.count
  end
  
  def test_index
    get :index,
      :account_code=>ACCOUNT_CODE_ORDINARY_DIPOSIT,
      :branch_id=>nil

    assert_response :success
  end

  def test_file_upload
    num_journal_headers = JournalHeader.count
    
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
    
    # 領収書ファイルアップロードのテスト
    assert_response :redirect
    assert_redirected_to :action =>:index
    assert_equal num_journal_headers + 1, JournalHeader.count
    
    list = JournalHeader.find_all_by_remarks('アップロードテスト')
    assert_equal 1, list.length
    jh = list[0]
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
    assert_template 'list'
    assert_not_nil assigns(:slip)
    assert_not_nil assigns(:slip).errors
    assert_not_nil assigns(:slip).journal_header.journal_details[0].errors[:sub_account]
  end

end
