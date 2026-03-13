require 'test_helper'

class Mm::DonationRecipientsHelperTest < ActionView::TestCase
  include Mm::DonationRecipientsHelper

  def test_donation_recipient_kind_label
    assert_equal '指定寄附金等', donation_recipient_kind_label(SUB_ACCOUNT_CODE_DONATION_DESIGNATED)
    assert_equal '指定寄附金等', donation_recipient_kind_label('100')
  end

  def test_donation_recipient_kind_options
    options = donation_recipient_kind_options
    assert_equal 3, options.size
    assert options.any? { |label, code| code == '100' && label.present? }
  end
end
