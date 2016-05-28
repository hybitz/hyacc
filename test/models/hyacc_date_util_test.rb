require 'test_helper'

class HyaccDateUtilTest < ActiveSupport::TestCase

  def test_get_year_months
    year_months = HyaccDateUtil.get_year_months( 200612, 12 )
    assert_equal( 200612, year_months[0] )
    assert_equal( 200701, year_months[1] )
    assert_equal( 200702, year_months[2] )
    assert_equal( 200703, year_months[3] )
    assert_equal( 200704, year_months[4] )
    assert_equal( 200705, year_months[5] )
    assert_equal( 200706, year_months[6] )
    assert_equal( 200707, year_months[7] )
    assert_equal( 200708, year_months[8] )
    assert_equal( 200709, year_months[9] )
    assert_equal( 200710, year_months[10] )
    assert_equal( 200711, year_months[11] )
  end
  
  def test_get_start_year_month_of_fiscal_year
    assert_equal( 200612, HyaccDateUtil.get_start_year_month_of_fiscal_year( 2007, 12 ) )
  end
  
  def test_get_ym_list
    list = HyaccDateUtil.get_ym_list( 2007, 2, 3 )
    assert_equal( 2005, list.first )
    assert_equal( 2010, list.last )
  end
  
  def test_last_day_of_month
    assert_equal( 31, HyaccDateUtil.last_day_of_month( 200701 ) )
    assert_equal( 28, HyaccDateUtil.last_day_of_month( 200702 ) )
    assert_equal( 31, HyaccDateUtil.last_day_of_month( 200703 ) )
  end
  
  def test_add_months
    assert_equal 200712, HyaccDateUtil.add_months(200812, -12)
    assert_equal 200801, HyaccDateUtil.add_months(200812, -11)
    assert_equal 200802, HyaccDateUtil.add_months(200812, -10)
    assert_equal 200803, HyaccDateUtil.add_months(200812, -9)
    assert_equal 200804, HyaccDateUtil.add_months(200812, -8)
    assert_equal 200805, HyaccDateUtil.add_months(200812, -7)
    assert_equal 200806, HyaccDateUtil.add_months(200812, -6)
    assert_equal 200807, HyaccDateUtil.add_months(200812, -5)
    assert_equal 200808, HyaccDateUtil.add_months(200812, -4)
    assert_equal 200809, HyaccDateUtil.add_months(200812, -3)
    assert_equal 200810, HyaccDateUtil.add_months(200812, -2)
    assert_equal 200811, HyaccDateUtil.add_months(200812, -1)
    assert_equal 200812, HyaccDateUtil.add_months(200812, 0)
    assert_equal 200901, HyaccDateUtil.add_months(200812, 1)
    assert_equal 200902, HyaccDateUtil.add_months(200812, 2)
    assert_equal 200903, HyaccDateUtil.add_months(200812, 3)
    assert_equal 200904, HyaccDateUtil.add_months(200812, 4)
    assert_equal 200905, HyaccDateUtil.add_months(200812, 5)
    assert_equal 200906, HyaccDateUtil.add_months(200812, 6)
    assert_equal 200907, HyaccDateUtil.add_months(200812, 7)
    assert_equal 200908, HyaccDateUtil.add_months(200812, 8)
    assert_equal 200909, HyaccDateUtil.add_months(200812, 9)
    assert_equal 200910, HyaccDateUtil.add_months(200812, 10)
    assert_equal 200911, HyaccDateUtil.add_months(200812, 11)
    assert_equal 200912, HyaccDateUtil.add_months(200812, 12)
  end
  
  def test_get_remaining_months
    start_month = 1
    assert_equal 12, HyaccDateUtil.get_remaining_months(start_month, 200901)
    assert_equal 11, HyaccDateUtil.get_remaining_months(start_month, 200902)
    assert_equal 10, HyaccDateUtil.get_remaining_months(start_month, 200903)
    assert_equal 9, HyaccDateUtil.get_remaining_months(start_month, 200904)
    assert_equal 8, HyaccDateUtil.get_remaining_months(start_month, 200905)
    assert_equal 7, HyaccDateUtil.get_remaining_months(start_month, 200906)
    assert_equal 6, HyaccDateUtil.get_remaining_months(start_month, 200907)
    assert_equal 5, HyaccDateUtil.get_remaining_months(start_month, 200908)
    assert_equal 4, HyaccDateUtil.get_remaining_months(start_month, 200909)
    assert_equal 3, HyaccDateUtil.get_remaining_months(start_month, 200910)
    assert_equal 2, HyaccDateUtil.get_remaining_months(start_month, 200911)
    assert_equal 1, HyaccDateUtil.get_remaining_months(start_month, 200912)
    
    start_month = 12
    assert_equal 12, HyaccDateUtil.get_remaining_months(start_month, 200812)
    assert_equal 11, HyaccDateUtil.get_remaining_months(start_month, 200901)
    assert_equal 10, HyaccDateUtil.get_remaining_months(start_month, 200902)
    assert_equal 9, HyaccDateUtil.get_remaining_months(start_month, 200903)
    assert_equal 8, HyaccDateUtil.get_remaining_months(start_month, 200904)
    assert_equal 7, HyaccDateUtil.get_remaining_months(start_month, 200905)
    assert_equal 6, HyaccDateUtil.get_remaining_months(start_month, 200906)
    assert_equal 5, HyaccDateUtil.get_remaining_months(start_month, 200907)
    assert_equal 4, HyaccDateUtil.get_remaining_months(start_month, 200908)
    assert_equal 3, HyaccDateUtil.get_remaining_months(start_month, 200909)
    assert_equal 2, HyaccDateUtil.get_remaining_months(start_month, 200910)
    assert_equal 1, HyaccDateUtil.get_remaining_months(start_month, 200911)
  end
  
  def test_last_month
    assert_equal 200901, HyaccDateUtil.last_month(200902)
    assert_equal 200902, HyaccDateUtil.last_month(200903)
    assert_equal 200903, HyaccDateUtil.last_month(200904)
    assert_equal 200904, HyaccDateUtil.last_month(200905)
    assert_equal 200905, HyaccDateUtil.last_month(200906)
    assert_equal 200906, HyaccDateUtil.last_month(200907)
    assert_equal 200907, HyaccDateUtil.last_month(200908)
    assert_equal 200908, HyaccDateUtil.last_month(200909)
    assert_equal 200909, HyaccDateUtil.last_month(200910)
    assert_equal 200910, HyaccDateUtil.last_month(200911)
    assert_equal 200911, HyaccDateUtil.last_month(200912)
    assert_equal 200912, HyaccDateUtil.last_month(201001)
  end
  
  def test_to_date
    assert_equal Date.new(2010, 1, 1), HyaccDateUtil.to_date(20100101)
    assert_equal Date.new(2010, 2, 4), HyaccDateUtil.to_date(20100204)
  end

  def test_get_ym_index
    assert_equal 11, HyaccDateUtil.get_ym_index(1, 201312)
    assert_equal 0, HyaccDateUtil.get_ym_index(1, 201401)
    assert_equal 1, HyaccDateUtil.get_ym_index(1, 201402)
    assert_equal 11, HyaccDateUtil.get_ym_index(12, 2014011)
    assert_equal 0, HyaccDateUtil.get_ym_index(12, 201412)
    assert_equal 1, HyaccDateUtil.get_ym_index(12, 201501)
  end
end
