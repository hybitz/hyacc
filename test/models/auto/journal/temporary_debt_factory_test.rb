require 'test_helper'

class Auto::Journal::TemporaryDebtFactoryTest < ActiveSupport::TestCase
  def test_仮負債精算の資産明細は部門コードではなくsub_account_idのbranch_idを使う
    source_branch = Branch.find(2)
    duplicate_branch = create_duplicate_branch(code: source_branch.code, parent_id: source_branch.parent_id)

    branch_code = duplicate_branch.code
    code_lookup_id = Branch.find_by_code(branch_code).id
    assert_equal source_branch.id, code_lookup_id
    assert_not_equal duplicate_branch.id, code_lookup_id

    source_detail = JournalDetail.new(
      account_id: Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT).id,
      sub_account_id: duplicate_branch.id,
      amount: 1200
    )

    params = {
      jh: journal,
      jd: source_detail,
      ym: journal.ym,
      day: journal.day,
      branch_id: source_branch.id,
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

    assets_debit_detail = transfer.journal_details[2]
    temp_assets_credit_detail = transfer.journal_details[3]

    assert_equal duplicate_branch.id, assets_debit_detail.branch_id
    assert_equal duplicate_branch.id, temp_assets_credit_detail.branch_id
  end

  private

  def create_duplicate_branch(code:, parent_id:)
    branch = Branch.new(
      company_id: user.employee.company.id,
      code: code,
      parent_id: parent_id,
      formal_name: '重複コード部門テスト',
      name: '重複コード部門テスト'
    )
    branch.save!
    branch
  end
end
