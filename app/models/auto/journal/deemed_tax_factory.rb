module Auto::Journal
  
  # みなし消費税仕訳ファクトリ
  class DeemedTaxFactory < Auto::AutoJournalFactory
    include HyaccDateUtil
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @fiscal_year = auto_journal_param.fiscal_year
      @user = auto_journal_param.user
      @logic = DeemedTax::DeemedTaxLogic.new(@fiscal_year)
    end

    def make_journals()
      ret = []
      
      @fiscal_year.year_month_range.each do |ym|
        jh = make_journal(ym)
        ret << jh if jh
      end

      # 年度で計算した額との差額を期末の仕訳に織り込む
      if ret.size > 0
        total_amount = @logic.get_deemed_tax_model().total_tax_amount
        diff_amount = ret.inject(total_amount){|total, jh| total - jh.amount}
        if diff_amount > 0
          last_jh = ret.last
          last_jh.amount += diff_amount
  
          # 租税公課の調整額
          jd = JournalDetail.new
          jd.detail_no = last_jh.journal_details.size + 1
          jd.dc_type = DC_TYPE_DEBIT
          jd.account_id = Account.get_by_code(ACCOUNT_CODE_TAX_AND_DUES).id
          jd.branch_id = @fiscal_year.company.get_head_office
          jd.amount = diff_amount
          jd.tax_type = TAX_TYPE_NONTAXABLE
          jd.note = '月別計算と年度計算の差額調整分'
          last_jh.journal_details << jd
          
          # 消費税の調整額
          jd2 = JournalDetail.new
          jd2.detail_no = jd.detail_no + 1
          jd2.dc_type = DC_TYPE_CREDIT
          jd2.account_id = Account.get_by_code(ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE).id
          jd2.branch_id = @fiscal_year.company.get_head_office
          jd2.amount = diff_amount
          jd2.tax_type = TAX_TYPE_NONTAXABLE
          jd2.note = '月別計算と年度計算の差額調整分'
          last_jh.journal_details << jd2
        end
      end
      
      ret
    end

    private

    def make_journal(ym)
      dtm = @logic.get_deemed_tax_model(ym, ym)
      
      # 納税額がない月の仕訳は不要
      return nil unless dtm.total_tax_amount > 0
      
      jh = JournalHeader.new
      jh.company_id = @fiscal_year.company.id
      jh.fiscal_year_id = @fiscal_year.id
      jh.ym = ym
      jh.day = last_day_of_month(ym)
      jh.slip_type = SLIP_TYPE_DEEMED_TAX
      jh.remarks = "みなし消費税　#{ym}分" 
      jh.amount = dtm.total_tax_amount
      jh.create_user_id = @user.id
      jh.update_user_id = @user.id
      
      # 租税公課
      jd = JournalDetail.new
      jd.detail_no = 1
      jd.dc_type = DC_TYPE_DEBIT
      jd.account_id = Account.get_by_code(ACCOUNT_CODE_TAX_AND_DUES).id
      jd.branch_id = @fiscal_year.company.get_head_office
      jd.amount = dtm.total_tax_amount
      jd.tax_type = TAX_TYPE_NONTAXABLE
      jh.journal_details << jd
      
      # 消費税
      jd2 = JournalDetail.new
      jd2.detail_no = 2
      jd2.dc_type = DC_TYPE_CREDIT
      jd2.account_id = Account.get_by_code(ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE).id
      jd2.branch_id = @fiscal_year.company.get_head_office
      jd2.amount = dtm.tax_amount
      jd2.tax_type = TAX_TYPE_NONTAXABLE
      jd2.note = '消費税'
      jh.journal_details << jd2
      
      # 地方消費税
      # 国に収める消費税の25％なので、消費税が4円未満だと0円の可能性がある
      if dtm.local_tax_amount > 0
        jd3 = JournalDetail.new
        jd3.detail_no = 3
        jd3.dc_type = DC_TYPE_CREDIT
        jd3.account_id = Account.get_by_code(ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE).id
        jd3.branch_id = @fiscal_year.company.get_head_office
        jd3.amount = dtm.local_tax_amount
        jd3.tax_type = TAX_TYPE_NONTAXABLE
        jd3.note = '地方消費税'
        jh.journal_details << jd3
      end
      
      jh
    end
  end
end
