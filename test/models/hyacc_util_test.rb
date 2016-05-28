require 'test_helper'

class HyaccUtilTest < ActiveSupport::TestCase

  def test_divide
    assert_equal( [], HyaccUtil.divide(1, 0) )
    assert_equal( [3,3,3,3], HyaccUtil.divide(12,4) )
    assert_equal( [4,3,3], HyaccUtil.divide(10,3) )
    assert_equal( [4,4,3], HyaccUtil.divide(11,3) )
  end
end
