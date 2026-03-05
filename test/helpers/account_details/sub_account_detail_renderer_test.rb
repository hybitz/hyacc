require 'test_helper'

class AccountDetails::SubAccountDetailRendererTest < ActiveSupport::TestCase
  def test_get_instance_寄付金でsub_account_idありでDonationRendererを返す
    account = Account.find_by(code: ACCOUNT_CODE_DONATION)
    sub_account_id = account.sub_accounts.first.id

    renderer = AccountDetails::SubAccountDetailRenderer.get_instance(account.id, sub_account_id)
    assert_instance_of AccountDetails::DonationRenderer, renderer
  end

  def test_get_instance_寄付金でsub_account_idなしでもDonationRendererを返す
    account_id = Account.find_by(code: ACCOUNT_CODE_DONATION).id
    renderer = AccountDetails::SubAccountDetailRenderer.get_instance(account_id, nil)
    assert_instance_of AccountDetails::DonationRenderer, renderer
  end
end
