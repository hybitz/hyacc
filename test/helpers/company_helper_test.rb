require 'test_helper'

class CompanyHelperTest < ActionView::TestCase
  
  def test_payday_to_jp
    assert_equal '当月25日', payday_to_jp(nil)
    assert_equal '当月25日', payday_to_jp("")
    assert_equal '当月1日', payday_to_jp("0,1")
    assert_equal '翌月7日', payday_to_jp("1,7")
    assert_equal '2ヶ月後25日', payday_to_jp("2,25")
    assert_equal '前月7日', payday_to_jp("-1,7")
    assert_equal '2ヶ月前25日', payday_to_jp("-2,25")
  end
  
  def test_month_of_payday
    assert_equal '0', month_of_payday(nil)
    assert_equal '0', month_of_payday("")
    assert_equal '1', month_of_payday("1,7")
    assert_equal '2', month_of_payday("2,25")
    assert_equal '-1', month_of_payday("-1,7")
  end
  
  def test_day_of_payday
    assert_equal '25', day_of_payday(nil)
    assert_equal '25', day_of_payday("")
    assert_equal '7', day_of_payday("1,7")
    assert_equal '25', day_of_payday("2,25")
    assert_equal '7', day_of_payday("-1,7")
  end
end
