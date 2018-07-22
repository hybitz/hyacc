module Auto::TransferJournal
  
  # 費用の自動配賦
  class AllocatedCostFactory < Auto::AutoJournalFactory

    def initialize( auto_journal_param )
      super( auto_journal_param )
      @src_jd = auto_journal_param.journal_detail
      @src_jh = @src_jd.journal_header
    end

    def make_journals
      make_journal_allocated_cost(@src_jd)
    end

    private

    def make_journal_allocated_cost(src_jd)
      jh = src_jd.transfer_journals.build(auto: true)
      jh.company_id = @src_jh.company_id
      jh.ym, jh.day = calc_ym_and_day(src_jd)
      jh.slip_type = SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST
      jh.remarks = @src_jh.remarks + '【費用配賦】'
      jh.create_user_id = @src_jh.create_user_id
      jh.update_user_id = @src_jh.update_user_id
      
      # 明細作成準備
      # 配賦用の勘定科目を特定
      a = Account.find(src_jd.account_id)
      if a.path.index(ACCOUNT_CODE_CORPORATE_TAXES)
        # 法人税等
        account_cost_share = Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_TAXES_SHARE)
        account_cost = Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_TAXES)
      else
        account_cost_share = Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST_SHARE)
        account_cost = Account.find_by_code(ACCOUNT_CODE_HEAD_OFFICE_COST)
      end
      
      # 配賦明細の作成
      JournalUtil.make_allocated_cost(src_jd.amount, src_jd.allocation_type, src_jd.branch).each do |branch_id, cost|
        # 本社費用負担
        jd = jh.journal_details.build
        jd.detail_no = jh.journal_details.size
        jd.dc_type = DC_TYPE_DEBIT
        jd.account_id = account_cost_share.id
        jd.branch_id = branch_id
        jd.amount = cost

        # 本社費用配賦
        jd2 = jh.journal_details.build
        jd2.detail_no = jh.journal_details.size
        jd2.dc_type = DC_TYPE_CREDIT
        jd2.account_id = account_cost.id
        jd2.sub_account_id = account_cost.get_sub_account_by_code( Branch.find(branch_id).code ).id
        jd2.branch_id = src_jd.branch_id
        jd2.amount = cost
      end
    end
    
    def calc_ym_and_day(jd)
      ajt = jd.auto_journal_type.to_i
      
      if ajt == AUTO_JOURNAL_TYPE_PREPAID_EXPENSE
        ym = HyaccDateUtil.next_month( jd.journal_header.ym ) 
        [ ym, 1 ]
      elsif ajt == AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE
        ym = HyaccDateUtil.last_month( jd.journal_header.ym )
        [ ym, HyaccDateUtil.last_day_of_month(ym) ]
      elsif ajt == AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE
        [ jd.auto_journal_year.to_i * 100 + jd.auto_journal_month.to_i, jd.auto_journal_day.to_i ]
      else
        [ jd.journal_header.ym, jd.journal_header.day ]
      end
    end
  end
end
