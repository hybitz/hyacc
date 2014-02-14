# -*- encoding : utf-8 -*-
#
# $Id: allocated_assets_factory.rb 2740 2011-12-12 15:00:19Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::TransferJournal
  
  # 資産の自動配賦
  class AllocatedAssetsFactory < Auto::AutoJournalFactory
    include Auto::TransferJournal::TransferJournalUtil
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @src_jd = auto_journal_param.journal_detail
      @src_jh = @src_jd.journal_header
    end
    
    def make_journals()
      transfer_journal = make_journal_allocated_assets(@src_jd)
      @src_jd.transfer_journals << transfer_journal
    end
    
  private  
    def make_journal_allocated_assets(src_jd)
      jh = JournalHeader.new
      jh.company_id = @src_jh.company_id
      jh.ym = @src_jh.ym
      jh.day = @src_jh.day
      jh.slip_type = SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS
      jh.remarks = get_remarks(@src_jh.remarks, src_jd.account_id)
      jh.create_user_id = @src_jh.create_user_id
      jh.created_on = @src_jh.created_on
      jh.update_user_id = @src_jh.update_user_id
      jh.updated_on = @src_jh.updated_on
      
      # 明細作成準備
      # 仮資産
      temp_assets = Account.get_by_code(ACCOUNT_CODE_TEMPORARY_ASSETS)
      # 仮負債
      temp_debt = Account.get_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
      
      # 部門情報取得
      src_branch = Branch.get(src_jd.branch_id)
      parent = src_branch.is_head_office == true ? src_branch : src_branch.parent
      allocated_costs = make_allocated_cost(parent.id, src_jd.amount)
      # 資産明細の作成
      detail_no = 0
      allocated_costs.each do |branch_id, cost|
        # サブ部門の場合は自身の仮負債を作成しない
        next if not src_branch.is_head_office and branch_id == src_jd.branch_id
        # 仮資産（借方）
        detail_no += 1
        jd = JournalDetail.new
        jd.detail_no = detail_no
        jd.dc_type = DC_TYPE_DEBIT
        jd.account_id = temp_assets.id
        jd.branch_id = src_jd.branch_id
        jd.amount = cost
        jd.created_on = src_jd.created_on
        jd.updated_on = src_jd.updated_on
        jh.journal_details << jd
        # 仮負債（貸方）
        detail_no += 1
        jd2 = JournalDetail.new
        jd2.detail_no = detail_no
        jd2.dc_type = DC_TYPE_CREDIT
        jd2.account_id = temp_debt.id
        jd2.sub_account_id = temp_debt.get_sub_account_by_code( Branch.get(src_jd.branch_id).code ).id
        jd2.branch_id = branch_id
        jd2.amount = cost
        jd2.created_on = src_jd.created_on
        jd2.updated_on = src_jd.updated_on
        jh.journal_details << jd2
      end
      
      jh
    end
  end
end
