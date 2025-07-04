require 'test_helper'

class NotificationHelperTest < ActionView::TestCase
  def test_formatted_message
    n = Notification.first
    assert_equal "令和7年の算定基礎届の提出期限は <span style=\"color: red;\">7月10日</span> です。", formatted_message(n)
  end
end