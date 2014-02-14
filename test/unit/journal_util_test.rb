# coding: UTF-8
#
# $Id: journal_util_test.rb 3072 2013-06-21 05:44:58Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class JournalUtilTest < ActiveRecord::TestCase
  include JournalUtil
  
  def test_clear_detail_attributes
    jd = clear_detail_attributes(JournalDetail.find(3))
    assert_equal 3, jd.id
    assert_nil jd.journal_header_id
    assert_nil jd.detail_no
    assert_nil jd.dc_type
    assert_nil jd.account_id
    assert_nil jd.sub_account_id
    assert_nil jd.branch_id
    assert_nil jd.amount
    assert_nil jd.updated_on
    assert_nil jd.note
    assert_nil jd.social_expense_number_of_people
    assert_equal DETAIL_TYPE_NORMAL, jd.detail_type
    assert_equal TAX_TYPE_NONTAXABLE, jd.tax_type
    assert_nil jd.main_detail_id
  end

  def test_calc_amount
    assert_equal 100, calc_amount(TAX_TYPE_NONTAXABLE, 100, 5)
    assert_equal 96, calc_amount(TAX_TYPE_INCLUSIVE, 100, 4)
    assert_equal 100, calc_amount(TAX_TYPE_EXCLUSIVE, 100, 5)
  end
  
  def test_copy_journal
    list = []
    list << JournalHeader.find(5880)
    
    list.each do |jh|
      copy = copy_journal(jh)
      assert_not_equal jh, copy
      assert_nil copy.id
      assert_equal jh.ym, copy.ym
      assert_equal jh.day, copy.day
      assert_equal jh.amount, copy.amount
      assert_equal jh.remarks, copy.remarks
      assert_equal jh.slip_type, copy.slip_type
      assert_equal jh.finder_key, copy.finder_key
      assert_equal jh.transfer_from_id, copy.transfer_from_id
      assert_equal jh.receipt_path, copy.receipt_path
      assert_equal jh.create_user_id, copy.create_user_id
      assert_equal jh.created_on, copy.created_on
      assert_equal jh.update_user_id, copy.update_user_id
      assert_equal jh.updated_on, copy.updated_on
      assert_equal jh.lock_version, copy.lock_version
      
      jh.journal_details.each_index do |i|
        jd = jh.journal_details[i]
        copy_jd = copy.journal_details[i]
        assert_not_equal jd, copy_jd
        assert_nil copy_jd.id
        assert_equal jd.journal_header_id, copy_jd.journal_header_id
        assert_equal jd.detail_no, copy_jd.detail_no
        assert_equal jd.dc_type, copy_jd.dc_type
        assert_equal jd.account_id, copy_jd.account_id
        assert_equal jd.sub_account_id, copy_jd.sub_account_id
        assert_equal jd.branch_id, copy_jd.branch_id
        assert_equal jd.amount, copy_jd.amount
        assert_equal jd.detail_type, copy_jd.detail_type
        assert_equal jd.tax_type, copy_jd.tax_type
        assert_equal jd.main_detail_id, copy_jd.main_detail_id
        assert_equal jd.is_allocated_cost, copy_jd.is_allocated_cost
        assert_equal jd.is_allocated_assets, copy_jd.is_allocated_assets
        assert_equal jd.account_name, copy_jd.account_name
        assert_equal jd.sub_account_name, copy_jd.sub_account_name
        assert_equal jd.branch_name, copy_jd.branch_name
        assert_equal jd.social_expense_number_of_people, copy_jd.social_expense_number_of_people
        assert_equal jd.note, copy_jd.note
        assert_equal jd.created_on, copy_jd.created_on
        assert_equal jd.updated_on, copy_jd.updated_on
        
        # コピーを編集しても元データに変更はない
        copy_jd.amount += 1
        copy_jd.asset = Asset.new
        assert_equal jd.amount + 1, copy_jd.amount
        assert_not_equal jd.asset, copy_jd.asset
      end
    end
  end

  def test_get_all_related_journals
    journal = JournalHeader.new
    journal.transfer_journals << JournalHeader.new
    journal.transfer_journals[0].transfer_journals << JournalHeader.new
    assert_equal(3, get_all_related_journals(journal).length)
    
    journal.transfer_journals << JournalHeader.new
    assert_equal(4, get_all_related_journals(journal).length)
  end

end
