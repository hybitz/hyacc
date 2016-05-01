require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
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

  def test_new_fiscal_year
    assert c = Company.first
    assert fy = c.new_fiscal_year
    assert_equal c.last_fiscal_year.fiscal_year + 1, fy.fiscal_year
    assert_equal c.last_fiscal_year.tax_management_type, fy.tax_management_type
    assert_equal c.last_fiscal_year.consumption_entry_type, fy.consumption_entry_type
    assert_equal CLOSING_STATUS_OPEN, fy.closing_status
  end

  def test_本部が取得できること
    c = Company.find(1)
    assert_not_nil(c)
    
    assert_nothing_raised "本部を取得できること" do
      c.get_head_office
    end
    assert_equal( true, c.get_head_office.is_head_office, "本部フラグがセットされていること")
  end
  
  def test_本社が取得できること
    c = Company.find(1)
    assert_not_nil(c)
    
    assert_nothing_raised "本社を取得できること" do
      c.get_head_business_office
    end
    assert_equal( true, c.get_head_business_office.is_head, "本部フラグがセットされていること")
  end

  def test_payday
    c = Company.new(:payday => nil)
    assert_equal '当月25日', c.payday_jp
    assert_equal 0, c.month_of_payday
    assert_equal 25, c.day_of_payday
    assert_equal 25, c.payroll_day(201501)

    c = Company.new(:payday => "")
    assert_equal '当月25日', c.payday_jp
    assert_equal 0, c.month_of_payday
    assert_equal 25, c.day_of_payday
    assert_equal 25, c.payroll_day(201501)

    c = Company.new(:payday => "0,1")
    assert_equal '当月1日', c.payday_jp
    assert_equal 0, c.month_of_payday
    assert_equal 1, c.day_of_payday
    assert_equal 1, c.payroll_day(201501)

    c = Company.new(:payday => "1,7")
    assert_equal '翌月7日', c.payday_jp
    assert_equal 1, c.month_of_payday
    assert_equal 7, c.day_of_payday
    assert_equal 31, c.payroll_day(201501)

    c = Company.new(:payday => "2,25")
    assert_equal '翌々月25日', c.payday_jp
    assert_equal 2, c.month_of_payday
    assert_equal 25, c.day_of_payday
    assert_equal 31, c.payroll_day(201501)

    c = Company.new(:payday => "3,25")
    assert_equal '3ヶ月後25日', c.payday_jp
    assert_equal 3, c.month_of_payday
    assert_equal 25, c.day_of_payday
    assert_equal 31, c.payroll_day(201501)
  end

end
