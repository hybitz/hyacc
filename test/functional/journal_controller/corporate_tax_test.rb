# coding: UTF-8
#
# $Id: corporate_tax_test.rb 3355 2014-02-07 02:27:50Z ichy $
# Product: hyacc
# Copyright 2010-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

# 振替伝票登録時に費用配賦の自動仕訳が正しく作成されているか
class JournalController::CorporateTaxTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:user2).id
  end
  
  def test_create_allocated_tax_cost
    a = Account.get_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
    sa = SubAccount.find(:first, :conditions=>['sub_account_type=? and code=?', SUB_ACCOUNT_TYPE_CORPORATE_TAX, '200'])

    num_journal_headers = JournalHeader.count
    post_jh = JournalHeader.new
    post_jh.remarks = '法人税等の決済区分テスト' + Time.now.to_s
    post_jh.ym = 200911
    post_jh.day = 25
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
    list = JournalHeader.find_all_by_ym_and_day(post_jh.ym,post_jh.day)
    
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
    
    jd = auto1.journal_details[0]
    assert_equal nil, jd.settlement_type
    
    jd = auto1.journal_details[1]
    assert_equal nil, jd.settlement_type
  end  
end
