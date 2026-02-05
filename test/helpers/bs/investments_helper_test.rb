require 'test_helper'

class Bs::InvestmentsHelperTest < ActionView::TestCase
  include Bs::InvestmentsHelper
  include HyaccConst

  def test_investment_form_locked_関連付け時はtrue
    investment = Investment.new
    investment.journal = Journal.new(slip_type: SLIP_TYPE_TRANSFER)
    assert investment_form_locked?(investment)
  end

  def test_investment_form_locked_新規で伝票なしはfalse
    investment = Investment.new
    assert_not investment_form_locked?(investment)
  end

  def test_investment_form_locked_編集時はfalse
    investment = investments(:attributes1)
    assert investment.persisted?
    assert_not investment_form_locked?(investment)
  end

  def test_investment_form_readonly_opts_ロック時はreadonly付き
    investment = Investment.new
    investment.journal = Journal.new(slip_type: SLIP_TYPE_TRANSFER)
    opts = investment_form_readonly_opts(investment)
    assert opts[:readonly]
    assert_equal 'readonly-as-disabled', opts[:class]
  end
end
