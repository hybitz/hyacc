# coding: UTF-8
#
# $Id: user_test.rb 3102 2013-07-24 14:47:54Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class UserTest < ActiveRecord::TestCase

  # 会社との関連があるか
  def test_company
    user = User.find_by_login_id('user1')
    assert_equal('株式会社テストA', user.company.name )
  end
end
