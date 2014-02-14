# -*- encoding : utf-8 -*-
#
# $Id: transfer_journal_util_test.rb 2740 2011-12-12 15:00:19Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

module Auto::TransferJournal
  class TransferJournalUtilTest < ActiveRecord::TestCase
    include Auto::TransferJournal::TransferJournalUtil

    test "資産配賦の摘要" do
      a = Account.get_by_code(ACCOUNT_CODE_CASH)
      assert_equal 'テスト【資産配賦】', get_remarks('テスト', a.id)
    end
    
    test "負債配賦の摘要" do
      a = Account.get_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE)
      assert_equal 'テスト【負債配賦】', get_remarks('テスト', a.id)
    end

    test "資産でも費用でもない勘定科目の場合の摘要" do
      a = Account.get_by_code(ACCOUNT_CODE_PAID_FEE)
      assert_raise(HyaccException) {
        get_remarks('テスト', a.id)
      }
    end
  end
end
