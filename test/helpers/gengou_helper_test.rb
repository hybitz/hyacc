require 'test_helper'

class GengouHelperTest < ActionView::TestCase

  def test_西暦から和暦
    assert_equal '平成元', to_wareki(1989)
  end

  def test_和暦から西暦
    assert_equal '1989', to_seireki('平成', 1) 
  end
end
