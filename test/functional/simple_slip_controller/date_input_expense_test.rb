# coding: UTF-8
#
# $Id: date_input_expense_test.rb 3367 2014-02-07 15:05:22Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

# 日付指定の計上日振替のテスト
class SimpleSlipController::DateInputExpenseTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:first).id
  end

  def test_本締の年度への費用振替_日付指定_の登録がエラーになること
    assert_equal CLOSING_STATUS_CLOSED, users(:first).company.get_fiscal_year(200610).closing_status
    
    post :create,
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "ym"=>200805,
        "day"=>17,
        "remarks"=>"タクシー代",
        "branch_id"=>2,
        "account_id"=>21,
        "amount_increase"=>1500,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE,
        "auto_journal_year"=>2006,
        "auto_journal_month"=>10,
        "auto_journal_day"=>12,
      }

    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:slip)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end

  def test_本締の年度への費用振替_日付指定_の更新がエラーになること
    assert_equal CLOSING_STATUS_CLOSED, users(:first).company.get_fiscal_year(200610).closing_status
    
    jh = JournalHeader.find(10)
    
    post :update, :format => 'js',
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "id"=>jh.id,
        "my_sub_account_id"=>"",
        "ym"=>200905,
        "day"=>17,
        "remarks"=>"タクシー代",
        "branch_id"=>2,
        "account_id"=>21,
        "amount_increase"=>1130,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "lock_version"=>jh.lock_version,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE,
        "auto_journal_year"=>2006,
        "auto_journal_month"=>10,
        "auto_journal_day"=>12,
      }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:slip)
    assert_equal ERR_CLOSING_STATUS_CLOSED, flash[:notice]
  end
  
  def test_仮締の年度への費用振替_日付指定_の登録が正常終了すること
    remarks = "仮締の年度への費用振替（日付指定）の登録が正常終了すること"
    assert_nil JournalHeader.find_by_remarks(remarks)
    assert_equal CLOSING_STATUS_CLOSING, users(:first).company.get_fiscal_year(200711).closing_status
    
    post :create,
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "ym"=>200805,
        "day"=>17,
        "remarks"=>remarks,
        "branch_id"=>2,
        "account_id"=>21,
        "amount_increase"=>1500,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE,
        "auto_journal_year"=>2007,
        "auto_journal_month"=>11,
        "auto_journal_day"=>15,
      }

    assert_response :redirect
    assert_redirected_to :action=>:index
    
    jh = JournalHeader.find_by_remarks(remarks)
    assert_not_nil jh
  end

  def test_仮締の年度への費用振替_日付指定_の更新が正常終了すること
    jh = JournalHeader.find(10)
    
    assert_equal CLOSING_STATUS_CLOSING, users(:first).company.get_fiscal_year(200711).closing_status
    
    post :update, :format => 'js',
      :account_code=>ACCOUNT_CODE_CASH,
      :slip => {
        "id"=>jh.id,
        "ym"=>200905,
        "day"=>17,
        "remarks"=>"仮締の年度への費用振替（日付指定）の更新が正常終了すること",
        "branch_id"=>2,
        "account_id"=>21,
        "amount_increase"=>1600,
        :tax_type => TAX_TYPE_NONTAXABLE,
        "lock_version"=>jh.lock_version,
        "auto_journal_type"=>AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE,
        "auto_journal_year"=>2007,
        "auto_journal_month"=>11,
        "auto_journal_day"=>15,
      }

    assert_response :success
    assert_template 'common/reload'
  end

end
