module Auto::Journal
  
  # 家事按分仕訳ファクトリ
  class HouseworkFactory < Auto::AutoJournalFactory
    include JournalUtil
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @housework = auto_journal_param.housework
      @user = auto_journal_param.user
    end

    def make_journals()
      # 前回作成した仕訳を破棄し、残高を仕訳作成前に戻す
      @housework.journal_headers.clear
      
      ret = []
      
      fy = FiscalYear.find_by_fiscal_year(@housework.fiscal_year)
      
      12.times do |i|
        ym = fy.fiscal_year * 100 + (i+1)
        jh = make_journal_by_month(ym)
        ret << jh if jh
      end
      
      ret
    end
    
    def make_journal_by_month(ym)
      jh = JournalHeader.new
      jh.company_id = @user.company.id
      jh.ym = ym
      jh.day = last_day_of_month(ym)
      jh.slip_type = SLIP_TYPE_HOUSEWORK
      jh.remarks = "家事按分#{ym}"
      jh.housework_id = @housework.id
      jh.create_user_id = @user.id
      jh.update_user_id = @user.id
      
      detail_no = 0
      @housework.details.each do |hwd|
        # 家事に相当する金額を算出
        net_sum_amount = VMonthlyLedger.get_net_sum_amount(ym, ym, hwd.account.id)
        next if net_sum_amount == 0
        
        business_amount = (net_sum_amount * hwd.business_ratio / 100).floor
        housework_amount = net_sum_amount - business_amount
        
        detail_no += 1
        jd = JournalDetail.new
        jd.detail_no = detail_no
        jd.dc_type = DC_TYPE_CREDIT
        jd.account_id = hwd.account_id
        jd.sub_account_id = hwd.sub_account_id
        jd.branch_id = @user.employee.default_branch.id
        jd.detail_type = DETAIL_TYPE_NORMAL
        jd.tax_type = TAX_TYPE_NONTAXABLE
        jd.housework_detail_id = hwd.id
        jd.amount = housework_amount
        jh.journal_details << jd
        
        detail_no += 1
        jd2 = JournalDetail.new
        jd2.detail_no = detail_no
        jd2.dc_type = DC_TYPE_DEBIT
        jd2.account_id = Account.get_by_code(ACCOUNT_CODE_CREDIT_BY_OWNER).id
        jd2.branch_id = jd.branch_id
        jd2.detail_type = DETAIL_TYPE_NORMAL
        jd2.tax_type = TAX_TYPE_NONTAXABLE
        jd2.housework_detail_id = hwd.id
        jd2.amount = housework_amount
        jh.journal_details << jd2
      end
      
      return nil if jh.journal_details.size == 0
      jh
    end
  end
end
