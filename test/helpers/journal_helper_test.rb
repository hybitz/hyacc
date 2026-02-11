require 'test_helper'

class JournalHelperTest < ActionView::TestCase

  def test_can_edit_通常の振替伝票
    jh = Journal.new(slip_type: SLIP_TYPE_TRANSFER, auto: false)
    assert can_edit(jh)
  end

  def test_can_edit_簡易入力の伝票
    jh = Journal.new(slip_type: SLIP_TYPE_SIMPLIFIED, auto: false)
    assert can_edit(jh)
  end

  def test_can_edit_給与伝票は編集不可
    jh = Journal.new(slip_type: SLIP_TYPE_AUTO_TRANSFER_PAYROLL, auto: false)
    assert_not can_edit(jh)
  end

  def test_can_edit_有価証券伝票は編集不可
    jh = Journal.new(slip_type: SLIP_TYPE_INVESTMENT, auto: false)
    assert_not can_edit(jh)
  end

  def test_can_edit_自動振替伝票は編集不可
    jh = Journal.new(slip_type: SLIP_TYPE_TRANSFER, auto: true)
    assert_not can_edit(jh)
  end

end
