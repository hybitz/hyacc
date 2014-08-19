require 'test_helper'

class EmployeesHelperTest < ActionView::TestCase
  
  def test_render_duration
    assert_equal '1ヶ月', render_duration(0, 0)
    assert_equal '4ヶ月', render_duration(0, 4)
    assert_equal '2年7ヶ月', render_duration(2, 7)
  end

end
