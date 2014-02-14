# coding: UTF-8
#
# $Id: allocated_cost_test.rb 3367 2014-02-07 15:05:22Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

# 振替伝票登録時に費用配賦の自動仕訳が正しく作成されているか
class JournalController::AllocatedCostTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:user3).id
  end
  
  def test_create_allocated_cost
    num_journal_headers = JournalHeader.count
    post_jh = JournalHeader.new
    post_jh.remarks = '費用配賦テスト' + Time.now.to_s
    post_jh.ym = 200908
    post_jh.day = 13
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = 20 # 福利厚生費
    post_jh.journal_details[0].tax_amount = 4
    post_jh.journal_details[0].input_amount = 100
    post_jh.journal_details[0].tax_type = TAX_TYPE_INCLUSIVE
    post_jh.journal_details[0].tax_rate_percent = 5
    post_jh.journal_details[0].is_allocated_cost = 1
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2
    
    post :create, :format => 'js',
      :journal_header => {
        :ym => post_jh.ym,
        :day => post_jh.day,
        :remarks => post_jh.remarks,
      },
      :journal_details => {
        '1' => {
          :branch_id => post_jh.journal_details[0].branch_id,
          :account_id => post_jh.journal_details[0].account_id,
          :tax_amount => post_jh.journal_details[0].tax_amount,
          :input_amount => post_jh.journal_details[0].input_amount,
          :tax_type => post_jh.journal_details[0].tax_type,
          :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
          :is_allocated_cost => true,
          :dc_type => post_jh.journal_details[0].dc_type,
          :detail_no => post_jh.journal_details[0].detail_no,
        },
        '2' => {
          :branch_id => post_jh.journal_details[1].branch_id,
          :account_id => post_jh.journal_details[1].account_id,
          :input_amount => post_jh.journal_details[1].input_amount,
          :tax_type => post_jh.journal_details[1].tax_type,
          :dc_type => post_jh.journal_details[1].dc_type,
          :detail_no => post_jh.journal_details[1].detail_no,
        }
      }

    assert_response :success
    assert_template 'common/reload'
    assert_equal num_journal_headers + 4, JournalHeader.count
    
    # 仕訳内容の確認
    list = JournalHeader.find_all_by_ym_and_day(post_jh.ym,post_jh.day)
    assert_equal 4, list.length, "自動仕訳が３つ作成されるので合計４仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 3, jh.journal_details.length, "消費税明細を含めて３明細"
    assert_equal 0, jh.transfer_journals.length, "内部取引仕訳は費用配賦仕訳に関連付けされる"
    assert_equal 1, jh.journal_details[0].transfer_journals.length
    
    # 自動仕訳（費用配賦）
    auto1 = jh.journal_details[0].transfer_journals[0]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal 4, auto1.journal_details.length, "２部門で４明細"
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200908, auto1.ym
    assert_equal 13, auto1.day
    assert_not_nil auto1.journal_details.find_by_account_id(73), "本社費用配賦の明細がある"
    assert_not_nil auto1.journal_details.find_by_account_id(74), "本社費用負担の明細がある"
    assert_equal 2, auto1.transfer_journals.length
    assert_equal 48, auto1.journal_details[0].amount, "税別で按分して￥４８"
    assert_equal 48, auto1.journal_details[1].amount, "税別で按分して￥４８"
    assert_equal 48, auto1.journal_details[2].amount, "税別で按分して￥４８"
    assert_equal 48, auto1.journal_details[3].amount, "税別で按分して￥４８"
    # 自動仕訳（本支店勘定１）
    auto2 = auto1.transfer_journals[0]
    assert_equal auto1.id, auto2.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto2.slip_type
    assert_not_nil auto2.journal_details.find_by_account_id(71), "支店勘定の明細がある"
    assert_not_nil auto2.journal_details.find_by_account_id(72), "本店勘定の明細がある"
    # 自動仕訳（本支店勘定２）
    auto3 = auto1.transfer_journals[1]
    assert_equal auto1.id, auto3.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto3.slip_type
    assert_not_nil auto3.journal_details.find_by_account_id(71), "支店勘定の明細がある"
    assert_not_nil auto3.journal_details.find_by_account_id(72), "本店勘定の明細がある"
  end
  
  def test_auto_journal_type_prepaid_expense
    num_journal_headers = JournalHeader.count
    remarks = '費用配賦テスト' + Time.now.to_s
    
    post_jh = JournalHeader.new
    post_jh.remarks = remarks
    post_jh.ym = 200908
    post_jh.day = 14
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = 20 # 福利厚生費
    post_jh.journal_details[0].tax_amount = 4
    post_jh.journal_details[0].input_amount = 100
    post_jh.journal_details[0].tax_type = TAX_TYPE_INCLUSIVE
    post_jh.journal_details[0].tax_rate_percent = 5
    post_jh.journal_details[0].is_allocated_cost = true
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].auto_journal_type = AUTO_JOURNAL_TYPE_PREPAID_EXPENSE
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].detail_no = 2
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    
    post :create, :format => 'js',
      :journal_header => {
        :ym => post_jh.ym,
        :day => post_jh.day,
        :remarks => post_jh.remarks,
      },
      :journal_details => {
        '1' => {
          :detail_no => post_jh.journal_details[0].detail_no,
          :branch_id => post_jh.journal_details[0].branch_id,
          :account_id => post_jh.journal_details[0].account_id,
          :tax_amount => post_jh.journal_details[0].tax_amount,
          :input_amount => post_jh.journal_details[0].input_amount,
          :tax_type => post_jh.journal_details[0].tax_type,
          :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
          :is_allocated_cost => post_jh.journal_details[0].is_allocated_cost,
          :dc_type => post_jh.journal_details[0].dc_type,
          :auto_journal_type => post_jh.journal_details[0].auto_journal_type,
        },
        '2' => {
          :detail_no => post_jh.journal_details[1].detail_no,
          :branch_id => post_jh.journal_details[1].branch_id,
          :account_id => post_jh.journal_details[1].account_id,
          :input_amount => post_jh.journal_details[1].input_amount,
          :tax_type => post_jh.journal_details[1].tax_type,
          :dc_type => post_jh.journal_details[1].dc_type,
        }
      }

    assert_response :success
    assert_template 'common/reload'
    assert_equal num_journal_headers + 6, JournalHeader.count, "自動仕訳が５つ作成されるので合計６仕訳"
    
    # 仕訳内容の確認
    jh = JournalHeader.find_all_by_remarks(remarks)[0]

    # 自動仕訳（費用配賦）は未払振替伝票の次に作成されるため、配列要素の２番目
    auto1 = jh.journal_details[0].transfer_journals[1]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200909, auto1.ym
    assert_equal 1, auto1.day
  end

  def test_auto_journal_type_accrued_expense
    num_journal_headers = JournalHeader.count
    remarks = '費用配賦テスト' + Time.now.to_s
    
    post_jh = JournalHeader.new
    post_jh.remarks = remarks
    post_jh.ym = 200908
    post_jh.day = 15
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = 20 # 福利厚生費
    post_jh.journal_details[0].tax_amount = 4
    post_jh.journal_details[0].input_amount = 100
    post_jh.journal_details[0].tax_type = TAX_TYPE_INCLUSIVE
    post_jh.journal_details[0].tax_rate_percent = 5
    post_jh.journal_details[0].is_allocated_cost = true
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].auto_journal_type = AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].detail_no = 2
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    
    post :create, :format => 'js',
      :journal_header => {
        :ym => post_jh.ym,
        :day => post_jh.day,
        :remarks => post_jh.remarks,
      },
      :journal_details => {
        '1' => {
          :detail_no => post_jh.journal_details[0].detail_no,
          :branch_id => post_jh.journal_details[0].branch_id,
          :account_id => post_jh.journal_details[0].account_id,
          :tax_amount => post_jh.journal_details[0].tax_amount,
          :input_amount => post_jh.journal_details[0].input_amount,
          :tax_type => post_jh.journal_details[0].tax_type,
          :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
          :is_allocated_cost => post_jh.journal_details[0].is_allocated_cost,
          :dc_type => post_jh.journal_details[0].dc_type,
          :auto_journal_type => post_jh.journal_details[0].auto_journal_type,
        },
        '2' => {
          :detail_no => post_jh.journal_details[1].detail_no,
          :branch_id => post_jh.journal_details[1].branch_id,
          :account_id => post_jh.journal_details[1].account_id,
          :input_amount => post_jh.journal_details[1].input_amount,
          :tax_type => post_jh.journal_details[1].tax_type,
          :dc_type => post_jh.journal_details[1].dc_type,
        }
      }

    assert_response :success
    assert_template 'common/reload'
    assert_equal num_journal_headers + 6, JournalHeader.count, "自動仕訳が５つ作成されるので合計６仕訳"
    
    # 仕訳内容の確認
    jh = JournalHeader.find_all_by_remarks(remarks)[0]

    # 自動仕訳（費用配賦）は前払振替伝票の次に作成されるため、配列要素の２番目
    auto1 = jh.journal_details[0].transfer_journals[1]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200907, auto1.ym
    assert_equal 31, auto1.day
  end

  def test_auto_journal_type_date_input_expense
    num_journal_headers = JournalHeader.count
    remarks = '費用配賦テスト' + Time.now.to_s
    
    post_jh = JournalHeader.new
    post_jh.remarks = remarks 
    post_jh.ym = 200908
    post_jh.day = 16
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = 20 # 福利厚生費
    post_jh.journal_details[0].tax_amount = 4
    post_jh.journal_details[0].input_amount = 100
    post_jh.journal_details[0].tax_type = TAX_TYPE_INCLUSIVE
    post_jh.journal_details[0].tax_rate_percent = 5
    post_jh.journal_details[0].is_allocated_cost = true
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details[0].auto_journal_type = AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE
    post_jh.journal_details[0].auto_journal_year = 2009
    post_jh.journal_details[0].auto_journal_month = 11
    post_jh.journal_details[0].auto_journal_day = 21
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2
    
    post :create, :format => 'js',
      :journal_header => {
        :ym => post_jh.ym,
        :day => post_jh.day,
        :remarks => post_jh.remarks,
      },
      :journal_details => {
        '1' => {
          :detail_no => post_jh.journal_details[0].detail_no,
          :branch_id => post_jh.journal_details[0].branch_id,
          :account_id => post_jh.journal_details[0].account_id,
          :tax_amount => post_jh.journal_details[0].tax_amount,
          :input_amount => post_jh.journal_details[0].input_amount,
          :tax_type => post_jh.journal_details[0].tax_type,
          :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
          :is_allocated_cost => post_jh.journal_details[0].is_allocated_cost,
          :dc_type => post_jh.journal_details[0].dc_type,
          :auto_journal_type => post_jh.journal_details[0].auto_journal_type,
          :auto_journal_year => post_jh.journal_details[0].auto_journal_year,
          :auto_journal_month => post_jh.journal_details[0].auto_journal_month,
          :auto_journal_day => post_jh.journal_details[0].auto_journal_day,
        },
        '2' => {
          :detail_no => post_jh.journal_details[1].detail_no,
          :branch_id => post_jh.journal_details[1].branch_id,
          :account_id => post_jh.journal_details[1].account_id,
          :input_amount => post_jh.journal_details[1].input_amount,
          :tax_type => post_jh.journal_details[1].tax_type,
          :dc_type => post_jh.journal_details[1].dc_type,
        }
      }

    assert_response :success
    assert_template 'common/reload'
    assert_equal num_journal_headers + 6, JournalHeader.count, "自動仕訳が５つ作成されるので合計６仕訳"
    
    # 仕訳内容の確認
    jh = JournalHeader.find_all_by_remarks(remarks)[0]

    # 自動仕訳（費用配賦）は計上日振替伝票の次に作成されるため、配列要素の２番目
    auto1 = jh.journal_details[0].transfer_journals[1]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200911, auto1.ym
    assert_equal 21, auto1.day
  end

  def test_create_allocated_tax_cost
    a = Account.get_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
    sa = SubAccount.find(:first, :conditions=>['sub_account_type=? and code=?', SUB_ACCOUNT_TYPE_CORPORATE_TAX, '200'])

    num_journal_headers = JournalHeader.count
    post_jh = JournalHeader.new
    post_jh.remarks = '法人税配賦テスト' + Time.now.to_s
    post_jh.ym = 200911
    post_jh.day = 3
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = a.id
    post_jh.journal_details[0].sub_account_id = sa.id
    post_jh.journal_details[0].settlement_type = SETTLEMENT_TYPE_FULL
    post_jh.journal_details[0].input_amount = 100000
    post_jh.journal_details[0].tax_type = 1
    post_jh.journal_details[0].is_allocated_cost = 1
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100000
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].is_allocated_assets = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2
    
    post :create, :format => 'js',
      :journal_header => {
        :ym => post_jh.ym,
        :day => post_jh.day,
        :remarks => post_jh.remarks,
      },
      :journal_details => {
        '1' => {
          :detail_no => post_jh.journal_details[0].detail_no,
          :branch_id => post_jh.journal_details[0].branch_id,
          :account_id => post_jh.journal_details[0].account_id,
          :sub_account_id => post_jh.journal_details[0].sub_account_id,
          :settlement_type => post_jh.journal_details[0].settlement_type,
          :input_amount => post_jh.journal_details[0].input_amount,
          :tax_type => post_jh.journal_details[0].tax_type,
          :is_allocated_cost => post_jh.journal_details[0].is_allocated_cost,
          :dc_type => post_jh.journal_details[0].dc_type,
        },
        '2' => {
          :detail_no => post_jh.journal_details[1].detail_no,
          :branch_id => post_jh.journal_details[1].branch_id,
          :account_id => post_jh.journal_details[1].account_id,
          :input_amount => post_jh.journal_details[1].input_amount,
          :tax_type => post_jh.journal_details[1].tax_type,
          :is_allocated_assets => post_jh.journal_details[1].is_allocated_assets,
          :dc_type => post_jh.journal_details[1].dc_type,
        }
      }

    assert_response :success
    assert_template 'common/reload'
    assert_equal num_journal_headers + 7, JournalHeader.count
    
    # 仕訳内容の確認
    list = JournalHeader.find_all_by_ym_and_day(post_jh. ym,post_jh.day)
    
    assert_equal 7, list.length, "自動仕訳が6つ作成されるので合計7仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 2, jh.journal_details.length, "２明細作成"
    assert_equal 1, jh.journal_details[0].transfer_journals.length
    
    # 自動仕訳（配賦）
    auto1 = jh.journal_details[0].transfer_journals[0]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal 4, auto1.journal_details.length, "２部門で４明細"
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_not_nil auto1.journal_details.find_by_account_id(86), "法人税配賦の明細がある"
    assert_not_nil auto1.journal_details.find_by_account_id(87), "法人税負担の明細がある"
  end
  
  
  def test_create_not_allocate_cost
    num_journal_headers = JournalHeader.count
    post_jh = JournalHeader.new
    post_jh.remarks = '費用配賦テスト' + Time.now.to_s
    post_jh.ym = 200908
    post_jh.day = 14
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = 20 # 福利厚生費
    post_jh.journal_details[0].tax_amount = 4
    post_jh.journal_details[0].input_amount = 100
    post_jh.journal_details[0].tax_type = TAX_TYPE_INCLUSIVE
    post_jh.journal_details[0].tax_rate_percent = 5
    post_jh.journal_details[0].is_allocated_cost = '0'
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2
    
    post :create, :format => 'js',
      :journal_header => {
        :ym => post_jh.ym,
        :day => post_jh.day,
        :remarks => post_jh.remarks,
      },
      :journal_details => {
        '1' => {
          :branch_id => post_jh.journal_details[0].branch_id,
          :account_id => post_jh.journal_details[0].account_id,
          :tax_amount => post_jh.journal_details[0].tax_amount,
          :input_amount => post_jh.journal_details[0].input_amount,
          :tax_type => post_jh.journal_details[0].tax_type,
          :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
          :is_allocated_cost => post_jh.journal_details[0].is_allocated_cost,
          :dc_type => post_jh.journal_details[0].dc_type,
          :detail_no => post_jh.journal_details[0].detail_no,
        },
        '2' => {
          :branch_id => post_jh.journal_details[1].branch_id,
          :account_id => post_jh.journal_details[1].account_id,
          :input_amount => post_jh.journal_details[1].input_amount,
          :tax_type => post_jh.journal_details[1].tax_type,
          :dc_type => post_jh.journal_details[1].dc_type,
          :detail_no => post_jh.journal_details[1].detail_no,
        }
      }

    assert_response :success
    assert_template 'common/reload'
    assert_equal num_journal_headers + 1, JournalHeader.count
    
    # 仕訳内容の確認
    list = JournalHeader.find_all_by_ym_and_day(post_jh.ym,post_jh.day)
    assert_equal 1, list.length, "自動仕訳が作成されない"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 3, jh.journal_details.length, "消費税明細を含めて３明細"
    assert_equal 0, jh.transfer_journals.length
  end
  
end
