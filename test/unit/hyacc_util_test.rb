# -*- encoding : utf-8 -*-
#
# $Id: hyacc_util_test.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class HyaccDateUtilTest < Test::Unit::TestCase
  include HyaccUtil

  def test_divide
    assert_equal( [], divide(1, 0) )
    assert_equal( [3,3,3,3], divide(12,4) )
    assert_equal( [4,3,3], divide(10,3) )
    assert_equal( [4,4,3], divide(11,3) )
  end
end
