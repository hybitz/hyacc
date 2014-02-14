# coding: UTF-8
#
# $Id: journal_header_test.rb 2928 2012-09-21 07:52:49Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class JournalHeaderTest < ActiveRecord::TestCase
  include HyaccConstants

  def setup
    # fixtureで検索キーを設定していないので、ARを一旦保存
    JournalHeader.find(:all).each do |jh|
      jh.save
    end
  end

  def test_ym
    jh = JournalHeader.find(1)

    # 年月が未設定は認めない
    jh.ym = nil
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }

    # 年月が空文字列は認めない
    jh.ym = ''
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }
    
    # 年月は数値6桁しか認めない
    jh.ym = 2007
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }
    
    # 正常系
    jh.ym = 200706
    assert jh.save!
  end
  
  def test_day
    jh = JournalHeader.find(1)
    
    # 日が未設定は認めない
    jh.ym = 200701
    jh.day = nil
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }

    # 日が空文字列は認めない
    jh.ym = 200701
    jh.day = ''
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }

    # 2007年1月は31日まで
    jh.ym = 200701
    jh.day = 31
    assert jh.save!
    jh.day = 32
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }
  end
  
  def test_find_by_finder_key
    # fixtureで検索キーを設定していないので、ARを一旦保存
    JournalHeader.find(:all).each{ |jh|
      jh.save
    }

    journals = JournalHeader.find(:all, :conditions=>["id <= 10 and finder_key rlike ?", ".*-8322,[0-9]*,1-.*"])
    assert_equal( 2, journals.length )
    
    # 検索条件がすべて１つの明細のものでなければヒットしない
    journals = JournalHeader.find(:all, :conditions=>["id <= 10 and finder_key rlike ?", ".*-8322,[0-9]*,2-.*"])
    assert_equal( 0, journals.length )
  end
  
  # 貸借の一致しない仕訳の登録がエラーになること
  def test_illegal_dc_amount
    jh = JournalHeader.new
    jh.company_id = 1
    jh.ym = 200906
    jh.day = 8
    jh.remarks = 'テスト'
    jh.create_user_id = 1
    jh.update_user_id = 1
    jh.journal_details << JournalDetail.new
    jh.journal_details[0].detail_no = 1
    jh.journal_details[0].detail_type = DETAIL_TYPE_NORMAL
    jh.journal_details[0].dc_type = DC_TYPE_DEBIT
    jh.journal_details[0].account_id = Account.find_by_code(ACCOUNT_CODE_CASH).id
    jh.journal_details[0].branch_id = Branch.find(1).id
    jh.journal_details[0].amount = 10000
    jh.journal_details << JournalDetail.new
    jh.journal_details[1].detail_no = 1
    jh.journal_details[1].detail_type = DETAIL_TYPE_NORMAL
    jh.journal_details[1].dc_type = DC_TYPE_CREDIT
    jh.journal_details[1].account_id = Account.find_by_code(ACCOUNT_CODE_CASH).id
    jh.journal_details[1].branch_id = Branch.find(1).id
    jh.journal_details[1].amount = 20000
    
    assert_raise( HyaccException ){ jh.save! }
  end
  
  # Trac#190
  def test_validate_fiscal_year
    jh = JournalHeader.find(1)
    
    assert_nothing_raised {
      jh.save!
    }
    
    jh.ym = 190001

    assert_raise( HyaccException ) {
      jh.save!
    }
  end
end
