require 'test_helper'

class Auto::TransferJournal::BranchCodeDuplicationTest < ActiveSupport::TestCase
  def setup
    @source_journal = Journal.new(
      company_id: user.employee.company.id,
      ym: '201604',
      day: 1,
      remarks: 'テスト',
      create_user_id: user.id,
      update_user_id: user.id
    )
    @source_branch = Branch.find(2)
    @destination_branch = Branch.find(3)
    @duplicate_branch = create_duplicate_branch(code: @source_branch.code, parent_id: @source_branch.parent_id)
  end

  def test_内部取引で部門補助科目はbranch_idを使う
    head_office = user.employee.company.head_branch

    account_branch_office = Account.find_by_code(ACCOUNT_CODE_BRANCH_OFFICE)
    code_lookup_id = account_branch_office.get_sub_account_by_code(@duplicate_branch.code).id
    assert_equal @source_branch.id, code_lookup_id
    assert_not_equal @duplicate_branch.id, code_lookup_id

    @source_journal.journal_details.build(
      detail_no: 1,
      dc_type: DC_TYPE_DEBIT,
      account_id: Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id,
      branch_id: @duplicate_branch.id,
      amount: 1000,
      tax_type: TAX_TYPE_NONTAXABLE,
      detail_type: DETAIL_TYPE_NORMAL
    )
    @source_journal.journal_details.build(
      detail_no: 2,
      dc_type: DC_TYPE_CREDIT,
      account_id: Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id,
      branch_id: head_office.id,
      amount: 1000,
      tax_type: TAX_TYPE_NONTAXABLE,
      detail_type: DETAIL_TYPE_NORMAL
    )

    factory = Auto::TransferJournal::InternalTradeFactory.new(
      Auto::TransferJournal::InternalTradeParam.new(@source_journal)
    )
    factory.make_journals

    transfer = @source_journal.transfer_journals.last
    assert_not_nil transfer

    head_office_detail = transfer.journal_details.find do |detail|
      detail.branch_id == head_office.id && detail.sub_account_id == @duplicate_branch.id
    end
    assert_not_nil head_office_detail
  end

  def test_費用配賦で部門補助科目は配賦先branch_idを使う
    sibling_ids = @destination_branch.self_and_siblings.map(&:id).sort
    assert_equal [@source_branch.id, @destination_branch.id, @duplicate_branch.id].sort, sibling_ids

    source_detail = JournalDetail.new(
      journal: @source_journal,
      account_id: Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id,
      branch_id: @destination_branch.id,
      dc_type: DC_TYPE_DEBIT,
      detail_type: DETAIL_TYPE_NORMAL,
      tax_type: TAX_TYPE_NONTAXABLE,
      amount: 1000,
      allocation_type: ALLOCATION_TYPE_EVEN_BY_SIBLINGS
    )

    factory = Auto::TransferJournal::AllocatedCostFactory.new(
      Auto::TransferJournal::TransferFromDetailParam.new(AUTO_JOURNAL_TYPE_ALLOCATED_COST, source_detail)
    )
    factory.make_journals

    transfer = source_detail.transfer_journals.last
    assert_not_nil transfer

    credit_details = transfer.journal_details.select do |detail|
      detail.dc_type == DC_TYPE_CREDIT && detail.branch_id == @destination_branch.id
    end
    assert_equal (sibling_ids - [@destination_branch.id]).sort, credit_details.map(&:sub_account_id).sort
  end

  def test_資産配賦で部門補助科目は起票元branch_idを使う
    sibling_ids = @duplicate_branch.self_and_siblings.map(&:id).sort
    assert_equal [@source_branch.id, @destination_branch.id, @duplicate_branch.id].sort, sibling_ids

    temp_debt = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    code_lookup_id = temp_debt.get_sub_account_by_code(@duplicate_branch.code).id
    assert_equal @source_branch.id, code_lookup_id
    assert_not_equal @duplicate_branch.id, code_lookup_id

    source_detail = JournalDetail.new(
      journal: @source_journal,
      account_id: Account.find_by_code(ACCOUNT_CODE_CASH).id,
      branch_id: @duplicate_branch.id,
      dc_type: DC_TYPE_DEBIT,
      detail_type: DETAIL_TYPE_NORMAL,
      tax_type: TAX_TYPE_NONTAXABLE,
      amount: 1000,
      allocation_type: ALLOCATION_TYPE_EVEN_BY_SIBLINGS
    )

    factory = Auto::TransferJournal::AllocatedAssetsFactory.new(
      Auto::TransferJournal::TransferFromDetailParam.new(AUTO_JOURNAL_TYPE_ALLOCATED_ASSETS, source_detail)
    )
    factory.make_journals

    transfer = source_detail.transfer_journals.last
    assert_not_nil transfer

    credit_details = transfer.journal_details.select { |detail| detail.dc_type == DC_TYPE_CREDIT }
    assert_equal (sibling_ids - [@duplicate_branch.id]).sort, credit_details.map(&:branch_id).sort
    assert_equal [@duplicate_branch.id], credit_details.map(&:sub_account_id).uniq
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
