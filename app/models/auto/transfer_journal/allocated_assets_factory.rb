module Auto::TransferJournal
  
  # 資産の自動配賦
  class AllocatedAssetsFactory < Auto::AutoJournalFactory

    def initialize( auto_journal_param )
      super( auto_journal_param )
      @src_jd = auto_journal_param.journal_detail
      @src_jh = @src_jd.journal_header
    end
    
    def make_journals
      jh = @src_jd.transfer_journals.build(auto: true)
      jh.company_id = @src_jh.company_id
      jh.date = @src_jh.date
      jh.slip_type = SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS
      jh.remarks = Auto::TransferJournal::TransferJournalUtil.get_remarks(@src_jh.remarks, @src_jd.account_id)
      jh.create_user_id = jh.update_user_id = @src_jh.update_user_id
      
      # 明細作成準備
      # 仮資産
      temp_assets = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_ASSETS)
      # 仮負債
      temp_debt = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
      
      # 資産明細の作成
      JournalUtil.make_allocated_cost(@src_jd).each do |branch_id, cost|
        # 自身の仮負債を作成しない
        next if branch_id == @src_jd.branch_id

        # 仮資産（借方）
        jd = jh.journal_details.build
        jd.detail_no = jh.journal_details.size
        jd.dc_type = DC_TYPE_DEBIT
        jd.account_id = temp_assets.id
        jd.branch_id = @src_jd.branch_id
        jd.amount = cost

        # 仮負債（貸方）
        jd2 = jh.journal_details.build
        jd2.detail_no = jh.journal_details.size
        jd2.dc_type = DC_TYPE_CREDIT
        jd2.account_id = temp_debt.id
        jd2.sub_account_id = temp_debt.get_sub_account_by_code(Branch.find(@src_jd.branch_id).code).id
        jd2.branch_id = branch_id
        jd2.amount = cost
      end
    end
  end
end
