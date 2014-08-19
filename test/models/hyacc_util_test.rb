require 'test_helper'

class HyaccDateUtilTest < ActiveSupport::TestCase
  include HyaccUtil

  def test_divide
    assert_equal( [], divide(1, 0) )
    assert_equal( [3,3,3,3], divide(12,4) )
    assert_equal( [4,3,3], divide(10,3) )
    assert_equal( [4,4,3], divide(11,3) )
  end
end
