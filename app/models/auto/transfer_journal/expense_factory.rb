# -*- encoding : utf-8 -*-
#
# $Id: expense_factory.rb 3064 2013-06-21 03:14:30Z ichy $
# Product: hyacc
# Copyright 2009-2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::TransferJournal
  
  # 費用の自動振替
  class ExpenseFactory < Auto::AutoJournalFactory
    include JournalUtil
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @src_jd = auto_journal_param.journal_detail
      @date = @src_jd.auto_journal_date
    end

    def make_journals()
      src_date = @src_jd.journal_header.date

      auto = JournalHeader.new
      auto.company_id = @src_jd.journal_header.company_id
      auto.ym = @date.year * 100 + @date.month
      auto.day = @date.day
      auto.remarks = @src_jd.journal_header.remarks + '【自動】'
      auto.slip_type = SLIP_TYPE_AUTO_TRANSFER_EXPENSE
      auto.create_user_id = @src_jd.journal_header.create_user_id
      auto.update_user_id = @src_jd.journal_header.update_user_id

      auto_jd = []
      auto_jd[0] = JournalDetail.new
      auto_jd[0].detail_no = 1
      auto_jd[0].dc_type = @src_jd.dc_type
      auto_jd[0].account_id = @src_jd.account_id
      auto_jd[0].sub_account_id = @src_jd.sub_account_id
      auto_jd[0].branch_id = @src_jd.branch_id
      auto_jd[0].amount = @src_jd.amount
      auto_jd[0].social_expense_number_of_people = @src_jd.social_expense_number_of_people

      # 繰越明細を作成
      auto_jd[1] = JournalDetail.new
      auto_jd[1].detail_no = 2
      auto_jd[1].dc_type = opposite_dc_type( auto_jd[0].dc_type )
      auto_jd[1].account_id = Account.get_by_code( src_date <= @date ? ACCOUNT_CODE_PREPAID_EXPENSE : ACCOUNT_CODE_ACCRUED_EXPENSE ).id
      auto_jd[1].sub_account_id = nil
      auto_jd[1].branch_id = auto_jd[0].branch_id
      auto_jd[1].amount = auto_jd[0].amount

      auto.journal_details = auto_jd
      @src_jd.transfer_journals << auto
      
      # 逆仕訳を作成
      reverse = JournalHeader.new
      reverse.company_id = auto.company_id
      reverse.ym = @src_jd.journal_header.ym
      reverse.day = @src_jd.journal_header.day
      reverse.remarks = auto.remarks + '【逆】'
      reverse.slip_type = auto.slip_type
      reverse.create_user_id = auto.create_user_id
      reverse.update_user_id = auto.update_user_id
      auto.journal_details.each do |jd|
        reverse_jd = JournalDetail.new
        reverse_jd.attributes = jd.attributes
        reverse_jd.dc_type = opposite_dc_type( jd.dc_type )
        reverse.journal_details << reverse_jd
      end

      auto.transfer_journals << reverse
    end
    
  end
end
