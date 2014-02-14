# coding: UTF-8
#
# $Id: withheld_tax_test.rb 3012 2013-03-06 15:35:44Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class WithheldTaxTest < ActiveRecord::TestCase
  fixtures :withheld_taxes

  def test_one
    withheld_tax = WithheldTax.find(1)
    assert_equal 1, withheld_tax.id
    assert_equal 200901, withheld_tax.apply_start_ym
    assert_equal 200912, withheld_tax.apply_end_ym
    assert_equal 1007000, withheld_tax.pay_range_above
    assert_equal 1010000, withheld_tax.pay_range_under
    assert_equal 130960, withheld_tax.no_dependent
    assert_equal 120510, withheld_tax.one_dependent
    assert_equal 112920, withheld_tax.two_dependent
    assert_equal 105640, withheld_tax.three_dependent
    assert_equal 98360, withheld_tax.four_dependent
    assert_equal 91070, withheld_tax.five_dependent
    assert_equal 83790, withheld_tax.six_dependent
    assert_equal 76990, withheld_tax.seven_dependent
  end
end
