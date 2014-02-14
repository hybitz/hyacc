# coding: UTF-8
#
# $Id: slip_utils_test.rb 2928 2012-09-21 07:52:49Z ichy $
# Product: hyacc
# Copyright 2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

module Slips
  class SlipUtilsTest < ActiveSupport::TestCase
    include HyaccConstants
    
    setup do
      @account = Account.get_by_code(ACCOUNT_CODE_CASH)
    end
    
    test '配賦のチェックがついている伝票は簡易伝票で編集できないこと' do
      jh = create_journal()
      assert SlipUtils.editable_as_simple_slip(jh, @account.id)

      jh.journal_details[0].is_allocated_cost = true
      assert ! SlipUtils.editable_as_simple_slip(jh, @account.id)
    end
    
    test 'すべて同じ計上部門の明細かどうか' do
      jh = create_journal()
      assert SlipUtils.is_all_same_branch(jh)

      jh.journal_details[0].branch_id = 1
      jh.journal_details[1].branch_id = 2
      assert ! SlipUtils.is_all_same_branch(jh)

      jh.journal_details[0].branch_id = 1
      jh.journal_details[1].branch_id = 1
      assert SlipUtils.is_all_same_branch(jh)
    end
    
    private
    def create_journal
      jh = JournalHeader.new
      jh.slip_type = SLIP_TYPE_TRANSFER
      
      jd1 = JournalDetail.new
      jd1.account_id = @account.id
      jh.journal_details << jd1
      
      jd2 = JournalDetail.new
      jh.journal_details << jd2
      
      jh
    end
  end
end