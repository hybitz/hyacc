# coding: UTF-8
#
# $Id: asset_test.rb 3355 2014-02-07 02:27:50Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class SimpleSlipController::AssetTest < ActionController::TestCase

  setup do
    @request.session[:user_id] = users(:first).id
  end

  # 償却待ち資産が存在する場合は削除不可
  def test_destroy_fail_by_depreciation_waiting
    jh = JournalHeader.find(6300)
    
    assert_equal CLOSING_STATUS_CLOSED, users(:first).company.get_fiscal_year(200610).closing_status
    
    post :destroy,
      :id=>jh.id,
      :lock_version=>0,
      :account_code=>ACCOUNT_CODE_CASH

    assert_response :redirect
    assert_redirected_to :action=>:index
    assert_nil assigns(:slip)
    assert_not_nil JournalHeader.find(6300)
  end
  
end
