require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  def test_カテゴリは必須
    notification = Notification.new(message: "テスト", category: nil)
    assert_not notification.valid?
    assert_includes notification.errors[:category], "を入力してください"
  end

end