# -*- encoding : utf-8 -*-
#
# $Id: account_test.rb 2489 2011-03-26 12:54:33Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class AccountTest < ActiveRecord::TestCase
  include HyaccUtil
  fixtures :accounts, :sub_accounts, :journal_headers, :journal_details

  def test_save_fail_by_account_type
    parent = Account.find(:first, :conditions=>["parent_id=0 and account_type=?", ACCOUNT_TYPE_ASSET])
    a = Account.new
    a.attributes = parent.attributes
    a.code = 'testcode'
    a.name = 'テスト名称'
    a.parent_id = parent.id
    
    a.account_type = ACCOUNT_TYPE_DEBT
    assert_equal( false, a.save, "親と違う勘定科目区分に変更はできない")
  end

  def test_save_fail_by_dc_type
    parent = Account.find(:first, :conditions=>["parent_id=0 and account_type=?", ACCOUNT_TYPE_ASSET])
    a = Account.new
    a.attributes = parent.attributes
    a.code = 'testcode'
    a.name = 'テスト名称'
    a.parent_id = parent.id
    
    a.dc_type = opposite_dc_type( parent.dc_type )
    assert_equal( false, a.save, "親と違う貸借区分に変更はできない")
  end
  
  def test_is_leaf_on_settlement_report
    a = Account.find_by_code('3170')
    assert_equal( true, a.is_leaf_on_settlement_report )

    a = Account.find_by_code('3171')
    assert_equal( false, a.is_leaf_on_settlement_report )

    a = Account.find_by_code('3172')
    assert_equal( false, a.is_leaf_on_settlement_report )
  end
  
end
