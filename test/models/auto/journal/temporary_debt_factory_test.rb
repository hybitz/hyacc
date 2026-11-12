require 'test_helper'

class Auto::Journal::TemporaryDebtFactoryTest < ActiveSupport::TestCase
  def test_仮負債精算の資産明細は補助科目のコードから部門を特定する_部門区分
    assets_branch = Branch.find(3)

    source_detail = JournalDetail.new(
      account_id: Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT).id,
      sub_account_id: assets_branch.id,
      amount: 1200
    )

    params = {
      jh: journal,
      jd: source_detail,
      ym: journal.ym,
      day: journal.day,
      branch_id: Branch.find(2).id,
      account_id: Account.find_by_code(ACCOUNT_CODE_CASH).id,
      sub_account_id: nil
    }

    factory = Auto::Journal::TemporaryDebtFactory.new(
      Auto::Journal::TemporaryDebtParam.new(params, user)
    )
    factory.make_journals

    transfer = journal.transfer_journals.last
    assert_not_nil transfer
    assert_equal 4, transfer.journal_details.size

    cash_id = Account.find_by_code(ACCOUNT_CODE_CASH).id
    temp_assets_id = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_ASSETS).id

    assets_debit_detail = transfer.journal_details.find { |d| d.dc_type == DC_TYPE_DEBIT && d.account_id == cash_id }
    temp_assets_credit_detail = transfer.journal_details.find { |d| d.dc_type == DC_TYPE_CREDIT && d.account_id == temp_assets_id }

    assert_not_nil assets_debit_detail
    assert_not_nil temp_assets_credit_detail

    assert_equal assets_branch.id, assets_debit_detail.branch_id
    assert_equal assets_branch.id, temp_assets_credit_detail.branch_id
  end

  def test_仮負債精算の資産明細は補助科目のコードから部門を特定する_通常区分
    temp_debt = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    assets_branch = Branch.find(3)
    sub_account = SubAccount.find_by!(account_id: temp_debt.id, code: assets_branch.code)
    assert_not_equal assets_branch.id, sub_account.id

    original_type = temp_debt.sub_account_type
    temp_debt.update_column(:sub_account_type, SUB_ACCOUNT_TYPE_NORMAL)
    Accounts::SubAccountsRequestCache.reset

    source_detail = JournalDetail.new(
      account_id: temp_debt.id,
      sub_account_id: sub_account.id,
      amount: 1200
    )

    params = {
      jh: journal,
      jd: source_detail,
      ym: journal.ym,
      day: journal.day,
      branch_id: Branch.find(2).id,
      account_id: Account.find_by_code(ACCOUNT_CODE_CASH).id,
      sub_account_id: nil
    }

    factory = Auto::Journal::TemporaryDebtFactory.new(
      Auto::Journal::TemporaryDebtParam.new(params, user)
    )
    factory.make_journals

    transfer = journal.transfer_journals.last
    cash_id = Account.find_by_code(ACCOUNT_CODE_CASH).id
    temp_assets_id = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_ASSETS).id

    assets_debit_detail = transfer.journal_details.find { |d| d.dc_type == DC_TYPE_DEBIT && d.account_id == cash_id }
    temp_assets_credit_detail = transfer.journal_details.find { |d| d.dc_type == DC_TYPE_CREDIT && d.account_id == temp_assets_id }

    assert_equal assets_branch.id, assets_debit_detail.branch_id
    assert_equal assets_branch.id, temp_assets_credit_detail.branch_id
  ensure
    temp_debt.update_column(:sub_account_type, original_type) if temp_debt && original_type
    Accounts::SubAccountsRequestCache.reset
  end
end
