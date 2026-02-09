require 'test_helper'

class CustomerTest < ActiveSupport::TestCase

  def test_コードの重複チェック
    a = Customer.new(valid_customer_params)
    assert a.save

    b = Customer.new(valid_customer_params(:code => a.code))
    assert b.invalid?
    assert b.errors[:code].include?(I18n.t('errors.messages.taken'))
  end

end
