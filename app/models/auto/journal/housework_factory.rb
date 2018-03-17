module Auto::Journal
  
  # 家事按分仕訳ファクトリ
  class HouseworkFactory < Auto::AutoJournalFactory
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @housework = auto_journal_param.housework
      @user = auto_journal_param.user
    end

    def make_journals
      # 前回作成した仕訳を破棄し、残高を仕訳作成前に戻す
      @housework.journal_headers.each do |jh|
        jh.mark_for_destruction
      end
      
      fy = FiscalYear.find_by_fiscal_year(@housework.fiscal_year)

      12.times do |i|
        ym = fy.fiscal_year * 100 + (i+1)
        make_journal_by_month(ym)
      end
      
      ret
    end
    
    def make_journal_by_month(ym)
      jh = @housework.journal_headers.build(auto: true)
      jh.company_id = @user.employee.company.id
      jh.ym = ym
      jh.day = HyaccDateUtil.last_day_of_month(ym)
      jh.slip_type = SLIP_TYPE_HOUSEWORK
      jh.remarks = "家事按分#{ym}"
      jh.create_user_id = @user.id
      jh.update_user_id = @user.id
      
      @housework.details.each do |hwd|
        # 家事に相当する金額を算出
        net_sum_amount = VMonthlyLedger.get_net_sum_amount(ym, ym, hwd.account.id)
        next if net_sum_amount == 0
        
        business_amount = (net_sum_amount * hwd.business_ratio / 100).floor
        housework_amount = net_sum_amount - business_amount
        
        jd = jh.journal_details.build
        jd.detail_no = jh.journal_details.size
        jd.dc_type = DC_TYPE_CREDIT
        jd.account_id = hwd.account_id
        jd.sub_account_id = hwd.sub_account_id
        jd.branch_id = @user.employee.default_branch.id
        jd.detail_type = DETAIL_TYPE_NORMAL
        jd.tax_type = TAX_TYPE_NONTAXABLE
        jd.housework_detail_id = hwd.id
        jd.amount = housework_amount

        jd = jh.journal_details.build
        jd.detail_no = jh.journal_details.size
        jd.dc_type = DC_TYPE_DEBIT
        jd.account_id = Account.find_by_code(ACCOUNT_CODE_CREDIT_BY_OWNER).id
        jd.branch_id = @user.employee.default_branch.id
        jd.detail_type = DETAIL_TYPE_NORMAL
        jd.tax_type = TAX_TYPE_NONTAXABLE
        jd.housework_detail_id = hwd.id
        jd.amount = housework_amount
      end
      
      jh.mark_for_destruction if jh.journal_details.empty?
    end
  end
end
