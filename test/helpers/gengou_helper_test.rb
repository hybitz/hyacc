require 'test_helper'
require 'date'

class GengouHelperTest < ActionView::TestCase

  def test_西暦から和暦
    assert_equal '平成元', to_wareki(Date.new(1989, 1, 8), format: '%y')
  end

  def test_平成
    assert heisei?(Date.new(1989,1,8))
  end

  def test_昭和
    assert syowa?(Date.new(1926,12,25))
  end

  def test_大正
    assert taisyo?(Date.new(1912,7,30))
  end

  def test_明治
    assert meiji?(Date.new(1911,12,31))
  end
end
