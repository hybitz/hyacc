require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def test_justify
    input = "経理太郎"
    expected = "<div class=\"justify\"><span>経</span><span>理</span><span>太</span><span>郎</span></div>"
    assert_equal expected, justify(input)
  end

  def test_flash_notice_renders_notice_lines_with_br
    flash[:notice] = ["エラー1", "エラー2"]
    result = flash_notice

    assert_match(/エラー1<br>エラー2/, result)
  end

  def test_flash_notice_escapes_notice_lines
    flash[:notice] = ["<script>alert(1)</script>", "エラー2"]
    result = flash_notice

    assert_match(/&lt;script&gt;alert\(1\)&lt;\/script&gt;<br>エラー2/, result)
  end

  def test_flash_notice_escapes_message
    flash[:notice] = "<a>地代"
    result = flash_notice

    assert_match(/&lt;a&gt;地代/, result)
  end

  def test_flash_notice_escapes_br_in_message
    flash[:notice] = "田中<br>さん を削除しました。"
    result = flash_notice

    assert_match(/田中&lt;br&gt;さん を削除しました。/, result)
    assert_no_match(/田中<br>さん/, result)
  end

  def test_flash_notice_renders_single_notice_line_without_br
    flash[:notice] = ["エラー1"]
    result = flash_notice

    assert_match(/エラー1/, result)
    assert_no_match(/<br>/, result)
  end
end
