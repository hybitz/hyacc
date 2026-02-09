require 'test_helper'

class Slips::SlipUtilsTest < ActiveSupport::TestCase

  setup do
    @account = Account.find_by_code(ACCOUNT_CODE_CASH)
  end
  
  test '配賦のチェックがついている伝票は簡易伝票で編集できないこと' do
    jh = create_journal()
    assert Slips::SlipUtils.editable_as_simple_slip(jh, @account.id)

    jh.journal_details[0].allocation_type = ALLOCATION_TYPE_EVEN_BY_SIBLINGS
    assert ! Slips::SlipUtils.editable_as_simple_slip(jh, @account.id)
  end
  
  test 'すべて同じ計上部門の明細かどうか' do
    jh = create_journal()
    assert Slips::SlipUtils.is_all_same_branch(jh)

    jh.journal_details[0].branch_id = 1
    jh.journal_details[1].branch_id = 2
    assert ! Slips::SlipUtils.is_all_same_branch(jh)

    jh.journal_details[0].branch_id = 1
    jh.journal_details[1].branch_id = 1
    assert Slips::SlipUtils.is_all_same_branch(jh)
  end
  
  private

  def create_journal
    jh = Journal.new
    jh.slip_type = SLIP_TYPE_TRANSFER
    
    jd1 = JournalDetail.new
    jd1.account_id = @account.id
    jh.journal_details << jd1
    
    jd2 = JournalDetail.new
    jh.journal_details << jd2
    
    jh
  end

end