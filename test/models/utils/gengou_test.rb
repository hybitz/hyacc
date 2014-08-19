require 'test_helper'
require 'gengou'

class GengouTest < ActiveSupport::TestCase

  def test_西暦から和暦
    assert_equal '平成元', Gengou.to_wareki(1989)
  end

  def test_和暦から西暦
    assert_equal '1989', Gengou.to_seireki('平成', 1) 
  end
end
