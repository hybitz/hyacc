require 'test_helper'

class Auto::TransferJournal::TransferJournalUtilTest < ActiveSupport::TestCase

  test "資産配賦の摘要" do
    a = Account.find_by_code(ACCOUNT_CODE_CASH)
    assert_equal 'テスト【資産配賦】', Auto::TransferJournal::TransferJournalUtil.get_remarks('テスト', a.id)
  end
  
  test "負債配賦の摘要" do
    a = Account.find_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE)
    assert_equal 'テスト【負債配賦】', Auto::TransferJournal::TransferJournalUtil.get_remarks('テスト', a.id)
  end

  test "資産でも費用でもない勘定科目の場合の摘要" do
    a = Account.find_by_code(ACCOUNT_CODE_PAID_FEE)
    assert_raise(HyaccException) {
      Auto::TransferJournal::TransferJournalUtil.get_remarks('テスト', a.id)
    }
  end

end
