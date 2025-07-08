require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def test_justify
    input = "経理太郎"
    expected = "<div class=\"justify\"><span>経</span><span>理</span><span>太</span><span>郎</span></div>"
    assert_equal expected, justify(input)
  end
end