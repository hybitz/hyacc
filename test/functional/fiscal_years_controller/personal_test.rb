# coding: UTF-8
#
# $Id: personal_test.rb 3355 2014-02-07 02:27:50Z ichy $
# Product: hyacc
# Copyright 2010-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

# 個人事業主の会計年度のテスト
class FiscalYearsController::PersonalTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = User.find(4).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:fiscal_years)
  end
  
  def test_confirm_carry_forward
    fy = FiscalYear.find(12)
    assert_equal CLOSING_STATUS_OPEN, fy.closing_status

    get :confirm_carry_forward, :id => fy.id, :format => 'js'

    assert_response :success
    assert_template :confirm_carry_forward
    assert_not_nil assigns(:fy)
  end

  def test_carry_forward
    fy = FiscalYear.find(10)
    assert_equal CLOSING_STATUS_OPEN, fy.closing_status

    post :carry_forward, :id => fy.id, :format => 'js',
      :lock_version => fy.lock_version,
      :journalize_housework => 0

    assert_response :success
    assert_template 'common/reload'
  end
end
