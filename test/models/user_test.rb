require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # 会社との関連があるか
  def test_company
    user = User.find_by_login_id('user1')
    assert_equal('株式会社テストA', user.company.name )
  end
end
