# -*- encoding : utf-8 -*-
#
# $Id: deemed_tax_factory_test.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

module Auto::Journal
  
  # みなし消費税仕訳ファクトリのテスト
  class DeemedTaxFactoryTest < ActiveRecord::TestCase
    include HyaccConstants
    
    # 売上がない年度のテスト
    def test_make_journals_no_sales
      c = Company.find(4)
      fy = c.get_fiscal_year(2009)
      u = User.find(5)
      factory = Auto::AutoJournalFactory.get_instance(DeemedTaxParam.new(fy, u))
      journals = factory.make_journals
      
      assert_not_nil journals
      assert_equal 0, journals.size
    end
    
    def test_make_journals
      c = Company.find(4)
      fy = c.get_fiscal_year(2010)
      u = User.find(5)
      factory = Auto::AutoJournalFactory.get_instance(DeemedTaxParam.new(fy, u))
      journals = factory.make_journals

      assert_not_nil journals
      assert_equal 4, journals.size
      
      jh = journals[0]
      assert_equal SLIP_TYPE_DEEMED_TAX, jh.slip_type
      assert_equal 201005, jh.ym
      assert_equal 31, jh.day
      assert_equal 5000, jh.amount
      
      jh = journals[1]
      assert_equal SLIP_TYPE_DEEMED_TAX, jh.slip_type
      assert_equal 201006, jh.ym
      assert_equal 30, jh.day
      assert_equal 2475, jh.amount
      
      jh = journals[2]
      assert_equal SLIP_TYPE_DEEMED_TAX, jh.slip_type
      assert_equal 201007, jh.ym
      assert_equal 31, jh.day
      assert_equal 2475, jh.amount
      
      jh = journals[3]
      assert_equal SLIP_TYPE_DEEMED_TAX, jh.slip_type
      assert_equal 201009, jh.ym
      assert_equal 30, jh.day
      assert_equal 2475, jh.amount
    end
  end
end
