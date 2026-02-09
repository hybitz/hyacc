module Auto::Journal
  
  # 減価償却仕訳ファクトリ
  class DepreciationFactory < Auto::AutoJournalFactory
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @depreciation = auto_journal_param.depreciation
      @user = auto_journal_param.user
    end

    def make_journals
      ret = []

      asset = @depreciation.asset
      c = asset.branch.company
      
      # 月数および償却開始月
      if @depreciation.fiscal_year == c.get_fiscal_year_int(asset.ym)
        num_of_months = HyaccDateUtil.get_remaining_months(c.start_month_of_fiscal_year, asset.ym)
        start_ym = asset.ym
      else
        num_of_months = 12
        start_ym = HyaccDateUtil.get_start_year_month_of_fiscal_year(@depreciation.fiscal_year, c.start_month_of_fiscal_year)
      end

      # 償却額を月数で分割。またその際に端数は切り捨てて、差異を初月に足しこむ
      amount_per_month = (@depreciation.amount_depreciated / num_of_months).truncate
      amount_fraction = @depreciation.amount_depreciated - (amount_per_month * num_of_months)
        
      num_of_months.times do |i|
        amount = amount_per_month
        amount += amount_fraction if i == 0

        jh = @depreciation.journals.build(auto: true)
        jh.company = c
        jh.slip_type = SLIP_TYPE_DEPRECIATION
        jh.ym = HyaccDateUtil.add_months(start_ym, i)
        jh.day = HyaccDateUtil.last_day_of_month(jh.ym)
        jh.remarks = "#{asset.code}：#{asset.name} 減価償却"
        jh.create_user_id = @user.id
        jh.update_user_id = @user.id
        
        jd = jh.journal_details.build
        jd.detail_no = jh.journal_details.size
        jd.dc_type = DC_TYPE_DEBIT
        jd.account_id = Account.find_by_code(ACCOUNT_CODE_DEPRECIATION).id
        jd.branch_id = asset.branch_id
        jd.tax_type = TAX_TYPE_NONTAXABLE
        jd.amount = amount
        
        jd = jh.journal_details.build
        jd.detail_no = jh.journal_details.size
        jd.dc_type = DC_TYPE_CREDIT
        jd.account_id = asset.account_id
        jd.sub_account_id = asset.journal_detail.sub_account_id
        jd.branch_id = asset.branch_id
        jd.tax_type = TAX_TYPE_NONTAXABLE
        jd.amount = amount

        ret << jh
      end

      ret
    end

  end
end
