require 'test_helper'

class SimpleSlipTest < ActiveSupport::TestCase

  def test_同じ科目はエラー
    account = Account.find_by_code(ACCOUNT_CODE_CASH)

    slip = SimpleSlip.new(:my_account_id => account.id, :account_id => account.id)
    assert slip.invalid?
    assert_equal I18n.t('errors.messages.accounts_duplicated'), slip.errors[:base].first
  end

end
