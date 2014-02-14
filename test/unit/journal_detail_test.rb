# coding: UTF-8
#
# $Id: journal_detail_test.rb 3367 2014-02-07 15:05:22Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class JournalDetailTest < ActiveRecord::TestCase
  
  def test_account_id_required

    # テスト前は正常に保存できることを前提とする
    @jd = JournalDetail.find(11573)
    assert_nothing_raised{ @jd.save! }

    # 未設定は認めない
    @jd.account_id = nil
    assert_raise( ActiveRecord::RecordInvalid ){ @jd.save! }
  end
  
  def test_branch_id_required

    # テスト前は正常に保存できることを前提とする
    @jd = JournalDetail.find(11573)
    assert_nothing_raised{ @jd.save! }

    # 未設定は認めない
    @jd.branch_id = nil
    assert_raise( ActiveRecord::RecordInvalid ){ @jd.save! }
  end
  
  def test_amount_required
    # テスト前は正常に保存できることを前提とする
    @jd = JournalDetail.find(11573)
    assert_nothing_raised{ @jd.save! }

    # 未設定は認めない
    @jd.amount = nil
    assert_raise( ActiveRecord::RecordInvalid ){ @jd.save! }
  end

  def test_消費税率の必須チェック
    @jd = JournalDetail.new
    @jd.tax_rate = ''
    
    @jd.tax_type = TAX_TYPE_NONTAXABLE
    assert @jd.tax_rate.blank?
    assert @jd.invalid?
    assert @jd.errors[:tax_rate].empty?

    @jd.tax_type = TAX_TYPE_INCLUSIVE
    assert @jd.tax_rate.blank?
    assert @jd.invalid?
    assert @jd.errors[:tax_rate].present?

    @jd.tax_type = TAX_TYPE_EXCLUSIVE
    assert @jd.tax_rate.blank?
    assert @jd.invalid?
    assert @jd.errors[:tax_rate].present?
  end
end
