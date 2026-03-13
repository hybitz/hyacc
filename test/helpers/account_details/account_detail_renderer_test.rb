require 'test_helper'

class AccountDetails::AccountDetailRendererTest < ActiveSupport::TestCase
  def test_get_instance_寄付金勘定ではnilを返す
    account_id = Account.find_by(code: ACCOUNT_CODE_DONATION).id
    renderer = AccountDetails::AccountDetailRenderer.get_instance(account_id)
    assert_nil renderer
  end
end
