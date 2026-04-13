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

  def test_子ども子育て支援金_202604_仕訳明細を作成する
    @payroll = Payroll.new(
      payroll_params.merge(
        employee_id: 1,
        ym: 202604,
        pay_day: '2026-05-07',
        base_salary: 300_000,
        monthly_standard: 300_000
      )
    )
    @payroll.calc_social_insurance

    employee_share = @payroll.child_and_childcare_support
    company_share = @payroll.child_and_childcare_support_all.to_i - employee_share
    assert employee_share > 0
    assert company_share > 0

    factory = Auto::AutoJournalFactory.get_instance(Auto::Journal::PayrollParam.new(@payroll, user))
    journal = factory.make_journals.first

    legal_welfare = Account.find_by_code(ACCOUNT_CODE_LEGAL_WELFARE)
    deposits_received = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
    sub_on_legal = legal_welfare.get_sub_account_by_code(TAX_DEDUCTION_TYPE_CHILD_AND_CHILDCARE_SUPPORT)
    sub_on_deposits = deposits_received.get_sub_account_by_code(TAX_DEDUCTION_TYPE_CHILD_AND_CHILDCARE_SUPPORT)

    company_line = journal.journal_details.find do |d|
      d.dc_type == DC_TYPE_DEBIT &&
        d.account_id == legal_welfare.id &&
        d.sub_account_id == sub_on_legal.id &&
        d.note == '会社負担子ども・子育て支援金'
    end
    assert_equal company_share, company_line.amount

    employee_line = journal.journal_details.find do |d|
      d.dc_type == DC_TYPE_CREDIT &&
        d.account_id == deposits_received.id &&
        d.sub_account_id == sub_on_deposits.id &&
        d.note == '個人負担子ども・子育て支援金'
    end
    assert_equal employee_share, employee_line.amount
  end

  def test_子ども子育て支援金_202603_仕訳明細を作成しない
    @payroll = Payroll.new(
      payroll_params.merge(
        employee_id: 1,
        ym: 202603,
        pay_day: '2026-04-07',
        base_salary: 300_000,
        monthly_standard: 300_000
      )
    )
    @payroll.calc_social_insurance
    assert_equal 0, @payroll.child_and_childcare_support

    factory = Auto::AutoJournalFactory.get_instance(Auto::Journal::PayrollParam.new(@payroll, user))
    journal = factory.make_journals.first

    legal_welfare = Account.find_by_code(ACCOUNT_CODE_LEGAL_WELFARE)
    deposits_received = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
    sub_on_legal = legal_welfare.get_sub_account_by_code(TAX_DEDUCTION_TYPE_CHILD_AND_CHILDCARE_SUPPORT)
    sub_on_deposits = deposits_received.get_sub_account_by_code(TAX_DEDUCTION_TYPE_CHILD_AND_CHILDCARE_SUPPORT)

    company_line = journal.journal_details.find do |d|
      d.dc_type == DC_TYPE_DEBIT &&
        d.account_id == legal_welfare.id &&
        d.sub_account_id == sub_on_legal.id &&
        d.note == '会社負担子ども・子育て支援金'
    end
    employee_line = journal.journal_details.find do |d|
      d.dc_type == DC_TYPE_CREDIT &&
        d.account_id == deposits_received.id &&
        d.sub_account_id == sub_on_deposits.id &&
        d.note == '個人負担子ども・子育て支援金'
    end
    assert_nil company_line
    assert_nil employee_line
  end
end
