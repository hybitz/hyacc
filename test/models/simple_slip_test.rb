require 'test_helper'

class SimpleSlipTest < ActiveSupport::TestCase

  def test_同じ科目はエラー
    account = Account.find_by_code(ACCOUNT_CODE_CASH)

    slip = SimpleSlip.new(:my_account_id => account.id, :account_id => account.id)
    assert slip.invalid?
    assert_equal I18n.t('errors.messages.accounts_duplicated'), slip.errors[:base].first
  end

  def test_自動振替
    my_account = Account.find_by_code(ACCOUNT_CODE_CASH)

    params = valid_simple_slip_params
    params = params.merge(:my_account_id => my_account.id,
        :company_id => branch.company_id, :create_user_id => branch.employees.first.user_id)

    slip = SimpleSlip.new(params)
    assert ! slip.id.present?
    assert_equal AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE, slip.auto_journal_type

    assert_difference 'Journal.count', 3 do
      assert_nothing_raised do
        assert slip.save!
        assert slip.id.present?
      end
    end

    assert jh = Journal.find_by_id(slip.id)
    assert_equal 3, jh.journal_details.size
    assert jd = jh.normal_details.find{|d| d.account_id != my_account.id }
    assert_equal 1, jd.transfer_journals.size
    assert auto = jd.transfer_journals.first
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE, auto.slip_type

    slip = SimpleSlip.build_from_journal(my_account.id, jh.id)
    assert_equal jh.id, slip.id
    assert slip.has_accrued_expense_transfers
    
    slip.auto_journal_type = nil

    assert_difference 'Journal.count', -2 do
      assert_nothing_raised do
        assert slip.save!
      end
    end
  end

  def test_save_寄付金かつ寄付先対象補助科目なら寄付先IDが保存される
    don = Account.find_by_code(ACCOUNT_CODE_DONATION)
    dr = donation_recipients(:one)
    sa = SubAccount.find_by(account_id: don.id, code: SUB_ACCOUNT_CODE_DONATION_DESIGNATED)
    slip = SimpleSlip.new(simple_slip_params(
      account_id: don.id, sub_account_id: sa.id, donation_recipient_id: dr.id
    ))
    assert slip.save!
    jd = Journal.find(slip.id).normal_details.find { |d| d.account_id == don.id }
    assert_equal dr.id, jd.donation_recipient_id
  end

  def test_save_寄付金かつ寄付先対象外補助科目なら寄付先IDは保存されない
    don = Account.find_by_code(ACCOUNT_CODE_DONATION)
    dr = donation_recipients(:one)
    others = SubAccount.find_by(account_id: don.id, code: SUB_ACCOUNT_CODE_DONATION_OTHERS)
    slip = SimpleSlip.new(simple_slip_params(
      account_id: don.id, sub_account_id: others.id, donation_recipient_id: dr.id
    ))
    assert slip.save!
    jd = Journal.find(slip.id).normal_details.find { |d| d.account_id == don.id }
    assert_nil jd.donation_recipient_id
  end

  def test_save_寄付金以外なら寄付先IDは保存されない
    dr = donation_recipients(:one)
    ar = Account.find_by_code(ACCOUNT_CODE_RECEIVABLE)
    slip = SimpleSlip.new(simple_slip_params(
      account_id: ar.id,
      sub_account_id: ar.sub_accounts.first.id,
      donation_recipient_id: dr.id
    ))
    assert slip.save!
    jd = Journal.find(slip.id).normal_details.find { |d| d.account_id == ar.id }
    assert_nil jd.donation_recipient_id
  end

  private

  def simple_slip_params(options = {})
    cash = Account.find_by_code(ACCOUNT_CODE_CASH)
    valid_simple_slip_params.merge(
      my_account_id: cash.id,
      company_id: branch.company_id,
      create_user_id: branch.employees.first.user_id,
      auto_journal_type: nil
    ).merge(options)
  end

end
