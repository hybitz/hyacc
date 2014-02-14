# -*- encoding : utf-8 -*-
#
# $Id: master_data_controller_test.rb 3164 2014-01-01 11:07:49Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class MasterDataControllerTest < ActionController::TestCase
  include HyaccUtil
  
  def setup
    @controller = MasterDataController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.session[:user_id] = users(:first).id
  end

  test "Trac#145 地代家賃の一覧が正しく取得できること" do
    get :get_sub_accounts,
      "format"=>"json",
      "account_id"=>"26",
      "order"=>"code"

    assert_response :success
  end
  
end
