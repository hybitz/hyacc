# -*- encoding : utf-8 -*-
#
# $Id: company_test.rb 2995 2013-02-15 08:22:39Z hiro $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class CompanyTest < ActiveRecord::TestCase
  fixtures :companies, :fiscal_years

  def test_get_fiscal_year_int
    assert_equal( 2007, companies(:a).get_fiscal_year_int( 200612 ) )
    assert_equal( 2006, companies(:a).get_fiscal_year_int( 200611 ) )
    assert_equal( 2007, companies(:a).get_fiscal_year_int( 200711 ) )
    assert_equal( 2008, companies(:a).get_fiscal_year_int( 200712 ) )

    assert_equal( 2005, companies(:b).get_fiscal_year_int( 200603 ) )
    assert_equal( 2006, companies(:b).get_fiscal_year_int( 200604 ) )
    assert_equal( 2006, companies(:b).get_fiscal_year_int( 200703 ) )
    assert_equal( 2007, companies(:b).get_fiscal_year_int( 200704 ) )
  end
  
  def test_get_fiscal_year
    assert_equal( 2006, companies(:a).get_fiscal_year( 200611 ).fiscal_year )
    assert_equal( 2007, companies(:a).get_fiscal_year( 200612 ).fiscal_year )
    assert_equal( 2007, companies(:a).get_fiscal_year( 200711 ).fiscal_year )
    assert_equal( 2008, companies(:a).get_fiscal_year( 200712 ).fiscal_year )

    assert_nil( companies(:b).get_fiscal_year( 200603 ) )
    assert_equal( 2006, companies(:b).get_fiscal_year( 200604 ).fiscal_year )
    assert_equal( 2006, companies(:b).get_fiscal_year( 200703 ).fiscal_year )
    assert_equal( 2007, companies(:b).get_fiscal_year( 200704 ).fiscal_year )
  end
  
  test "本部が取得できること" do
    c = Company.find(1)
    assert_not_nil(c)
    
    assert_nothing_raised "本部を取得できること" do
      c.get_head_office
    end
    assert_equal( true, c.get_head_office.is_head_office, "本部フラグがセットされていること")
  end
  
  test "本社が取得できること" do
    c = Company.find(1)
    assert_not_nil(c)
    
    assert_nothing_raised "本社を取得できること" do
      c.get_head_business_office
    end
    assert_equal( true, c.get_head_business_office.is_head, "本部フラグがセットされていること")
  end
end
