require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def test_justify
    input = "経理太郎"
    expected = "<div class=\"justify\"><span>経</span><span>理</span><span>太</span><span>郎</span></div>"
    assert_equal expected, justify(input)
  end

  def test_flash_notice_preserves_br_tag
    flash[:notice] = "エラー1<br/>エラー2"
    result = flash_notice

    assert_match(/エラー1<br>エラー2/, result)
  end

  def test_flash_notice_strips_script_tag_but_keeps_br
    flash[:notice] = "<script>alert(1)</script><br/>エラー2"
    result = flash_notice

    assert_no_match(/<script>/, result)
    assert_match(/alert\(1\)<br>エラー2/, result)
  end

  def test_flash_notice_strips_attributes_from_br_tag
    flash[:notice] = "エラー1<br onmouseover=\"alert(1)\">エラー2"
    result = flash_notice

    assert_no_match(/onmouseover/, result)
    assert_match(/エラー1<br>エラー2/, result)
  end
end
