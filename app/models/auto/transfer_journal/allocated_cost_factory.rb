# -*- encoding : utf-8 -*-
#
# $Id: allocated_cost_factory.rb 2474 2011-03-23 15:28:08Z ichy $
# Product: hyacc
# Copyright 2009-2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::TransferJournal
  
  # 費用の自動配賦
  class AllocatedCostFactory < Auto::AutoJournalFactory
    include JournalUtil
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @src_jd = auto_journal_param.journal_detail
      @src_jh = @src_jd.journal_header
    end

    def make_journals()
      transfer_journal = make_journal_allocated_cost(@src_jd)
      @src_jd.transfer_journals << transfer_journal
    end
    
  private
    def make_journal_allocated_cost(src_jd)
      jh = JournalHeader.new
      jh.company_id = @src_jh.company_id
      jh.ym, jh.day = calc_ym_and_day(src_jd)
      jh.slip_type = SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST
      jh.remarks = @src_jh.remarks + '【費用配賦】'
      jh.create_user_id = @src_jh.create_user_id
      jh.created_on = @src_jh.created_on
      jh.update_user_id = @src_jh.update_user_id
      jh.updated_on = @src_jh.updated_on
      
      # 明細作成準備
      # 配賦用の勘定科目を特定
      a = Account.get(src_jd.account_id)
      if a.path.index(ACCOUNT_CODE_SALES_AND_GENERAL_ADMINISTRATIVE_EXPENSE) != nil
        # 販売費および一般管理費
        account_cost_share = Account.get_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST_SHARE)
        account_cost = Account.get_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST)
      elsif a.path.index(ACCOUNT_CODE_CORPORATE_TAXES) != nil
        # 法人税等
        account_cost_share = Account.get_by_code(ACCOUNT_CODE_HEAD_OFFICE_TAXES_SHARE)
        account_cost = Account.get_by_code(ACCOUNT_CODE_HEAD_OFFICE_TAXES)
      else
        # その他
        account_cost_share = Account.get_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST_SHARE)
        account_cost = Account.get_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST)
      end
      
      # 配賦明細の作成
      detail_no = 0
      make_allocated_cost(src_jd.branch_id, src_jd.amount).each do |branch_id, cost|
        # 本社費用負担
        detail_no += 1
        jd = JournalDetail.new
        jd.detail_no = detail_no
        jd.dc_type = DC_TYPE_DEBIT
        jd.account_id = account_cost_share.id
        jd.branch_id = branch_id
        jd.amount = cost
        jd.created_on = src_jd.created_on
        jd.updated_on = src_jd.updated_on
        jh.journal_details << jd
        # 本社費用配賦
        detail_no += 1
        jd2 = JournalDetail.new
        jd2.detail_no = detail_no
        jd2.dc_type = DC_TYPE_CREDIT
        jd2.account_id = account_cost.id
        jd2.sub_account_id = account_cost.get_sub_account_by_code( Branch.find(branch_id).code ).id
        jd2.branch_id = src_jd.branch_id
        jd2.amount = cost
        jd2.created_on = src_jd.created_on
        jd2.updated_on = src_jd.updated_on
        jh.journal_details << jd2
      end
      return jh
    end
    
    def calc_ym_and_day(jd)
      ajt = jd.auto_journal_type.to_i
      
      if ajt == AUTO_JOURNAL_TYPE_PREPAID_EXPENSE
        ym = next_month( jd.journal_header.ym ) 
        [ ym, 1 ]
      elsif ajt == AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE
        ym = last_month( jd.journal_header.ym )
        [ ym, last_day_of_month(ym) ]
      elsif ajt == AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE
        [ jd.auto_journal_year.to_i * 100 + jd.auto_journal_month.to_i, jd.auto_journal_day.to_i ]
      else
        [ jd.journal_header.ym, jd.journal_header.day ]
      end
    end
  end
end
