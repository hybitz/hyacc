require 'test_helper'

class SequenceTest < ActiveSupport::TestCase

  def test_create_sequence
    assert_nothing_raised{
      Sequence.create_sequence("test")
    }
  end
  
  def test_next_value
    assert_equal 2, Sequence.next_value("Asset", "2009")
  end
end
