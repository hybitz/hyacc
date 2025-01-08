require 'test_helper'

class AnnualAdjustmentAccountValidatorTest < ActiveSupport::TestCase

  def test_存在しない勘定科目
    fy = FiscalYear.new

    fy.annual_adjustment_account_id = Account.maximum(:id) + 1
    assert fy.invalid?
    assert_includes fy.errors[:annual_adjustment_account_id], I18n.t('errors.messages.non_existing_account')
  end

  def test_補助科目に源泉徴収税が必要
    fy = FiscalYear.new

    fy.annual_adjustment_account_id = Account.find_by_code(ACCOUNT_CODE_CASH).id
    assert fy.invalid?
    assert_includes fy.errors[:annual_adjustment_account_id], I18n.t('errors.messages.income_tax_sub_account_required')
  end

end
