require 'test_helper'

class AccountDetails::AccountDetailRendererTest < ActiveSupport::TestCase
  def test_get_instance_寄付金勘定でDonationRendererを返す
    account_id = Account.find_by(code: ACCOUNT_CODE_DONATION).id
    renderer = AccountDetails::AccountDetailRenderer.get_instance(account_id)
    assert_instance_of AccountDetails::DonationRenderer, renderer
  end

  def test_donation_renderer_get_template
    account = Account.find_by(code: ACCOUNT_CODE_DONATION)
    renderer = AccountDetails::DonationRenderer.new(account)
    assert_equal 'journals/account_details/donation', renderer.get_template('journals')
  end
end
