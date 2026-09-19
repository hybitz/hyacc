require 'test_helper'

class SimpleSlipTemplateTest < ActiveSupport::TestCase

  def test_消費税率の未指定と0パーセントを区別できる
    t = SimpleSlipTemplate.new

    t.tax_rate_percent = ''
    assert_nil t.tax_rate
    assert_nil t.tax_rate_percent

    t.tax_rate_percent = 0
    assert_equal 0.0, t.tax_rate.to_f
    assert_equal 0, t.tax_rate_percent
  end

end
