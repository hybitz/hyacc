require 'test_helper'

class Auto::Journal::PayrollFactoryTest < ActiveSupport::TestCase

  def test_支払手数料に消費税が発生する場合は仮払消費税の仕訳明細を作成する
    @payroll = Payroll.new(payroll_params.merge(ym: '201603', pay_day:  '2016-03-06', transfer_fee: 1000))
    assert_equal TAX_MANAGEMENT_TYPE_EXCLUSIVE, user.employee.company.get_fiscal_year(@payroll.ym.to_i).tax_management_type
    factory = Auto::AutoJournalFactory.get_instance(Auto::Journal::PayrollParam.new(@payroll, user))
    journals = factory.make_journals

    assert_equal 3, journals.size

    jh = journals[2]
    assert_equal 3, jh.journal_details.size

    jd = jh.journal_details[0]
    assert_equal Account.find_by_code(ACCOUNT_CODE_COMMISSION_PAID).id, jd.account_id
    assert_equal 1000, jd.amount

    jd = jh.journal_details[1]
    assert_equal Account.find_by_code(ACCOUNT_CODE_TEMP_PAY_TAX).id, jd.account_id
    assert_equal 80, jd.amount

    jd = jh.journal_details[2]
    assert_equal Account.find_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT).id, jd.account_id
    assert_equal 1080, jd.amount
  end

  def test_支払手数料に消費税が発生しない場合は仮払消費税の仕訳明細を作成しない
    @payroll = Payroll.new(payroll_params.merge(ym: '201603', pay_day:  '2016-03-06', transfer_fee: 10))
    assert_equal TAX_MANAGEMENT_TYPE_EXCLUSIVE, user.employee.company.get_fiscal_year(@payroll.ym.to_i).tax_management_type
    factory = Auto::AutoJournalFactory.get_instance(Auto::Journal::PayrollParam.new(@payroll, user))
    journals = factory.make_journals

    assert_equal 3, journals.size

    jh = journals[2]
    assert_equal 2, jh.journal_details.size

    jd = jh.journal_details[0]
    assert_equal Account.find_by_code(ACCOUNT_CODE_COMMISSION_PAID).id, jd.account_id
    assert_equal 10, jd.amount

    jd = jh.journal_details[1]
    assert_equal Account.find_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT).id, jd.account_id
    assert_equal 10, jd.amount
  end
end