module Auto::TransferJournal
  
  # 資産の自動配賦
  class AllocatedAssetsFactory < Auto::AutoJournalFactory
    include Auto::TransferJournal::TransferJournalUtil
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @src_jd = auto_journal_param.journal_detail
      @src_jh = @src_jd.journal_header
    end
    
    def make_journals
      make_journal_allocated_assets(@src_jd)
    end
    
    private  

    def make_journal_allocated_assets(src_jd)
      jh = src_jd.transfer_journals.build(auto: true)
      jh.company_id = @src_jh.company_id
      jh.ym = @src_jh.ym
      jh.day = @src_jh.day
      jh.slip_type = SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS
      jh.remarks = get_remarks(@src_jh.remarks, src_jd.account_id)
      jh.create_user_id = @src_jh.create_user_id
      jh.created_at = @src_jh.created_at
      jh.update_user_id = @src_jh.update_user_id
      jh.updated_at = @src_jh.updated_at
      
      # 明細作成準備
      # 仮資産
      temp_assets = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_ASSETS)
      # 仮負債
      temp_debt = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
      
      # 部門情報取得
      src_branch = Branch.find(src_jd.branch_id)
      parent = src_branch.head_office? ? src_branch : src_branch.parent

      # 資産明細の作成
      JournalUtil.make_allocated_cost(parent.id, src_jd.amount).each do |branch_id, cost|
        # サブ部門の場合は自身の仮負債を作成しない
        next if not src_branch.head_office? and branch_id == src_jd.branch_id

        # 仮資産（借方）
        jd = jh.journal_details.build
        jd.detail_no = jh.journal_details.size
        jd.dc_type = DC_TYPE_DEBIT
        jd.account_id = temp_assets.id
        jd.branch_id = src_jd.branch_id
        jd.amount = cost
        jd.created_at = src_jd.created_at
        jd.updated_at = src_jd.updated_at

        # 仮負債（貸方）
        jd2 = jh.journal_details.build
        jd2.detail_no = jh.journal_details.size
        jd2.dc_type = DC_TYPE_CREDIT
        jd2.account_id = temp_debt.id
        jd2.sub_account_id = temp_debt.get_sub_account_by_code( Branch.find(src_jd.branch_id).code ).id
        jd2.branch_id = branch_id
        jd2.amount = cost
        jd2.created_at = src_jd.created_at
        jd2.updated_at = src_jd.updated_at
      end
    end
  end
end
