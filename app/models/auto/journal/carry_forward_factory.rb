module Auto::Journal
  
  # 個人事業主の年次繰越仕訳ファクトリ
  class CarryForwardFactory < Auto::AutoJournalFactory

    def initialize( auto_journal_param )
      super( auto_journal_param )
      @fiscal_year = auto_journal_param.fiscal_year
      @user = auto_journal_param.user
    end

    def make_journals
      # 今期の元入金
      personal_capital_account = Account.find_by_code(ACCOUNT_CODE_PERSONAL_CAPITAL)
      personal_capital = VMonthlyLedger.get_net_sum_amount(nil, @fiscal_year.end_year_month, personal_capital_account.id)
      HyaccLogger.debug "今期末の元入金：#{personal_capital}"

      # 今期の利益
      profit_account = Account.where(:account_type => ACCOUNT_TYPE_PROFIT, :parent_id => nil).first
      expense_account = Account.where(:account_type => ACCOUNT_TYPE_EXPENSE, :parent_id => nil).first
      profit = VMonthlyLedger.get_net_sum_amount( @fiscal_year.start_year_month, @fiscal_year.end_year_month, profit_account.id )
      expense = VMonthlyLedger.get_net_sum_amount( @fiscal_year.start_year_month, @fiscal_year.end_year_month, expense_account.id )
      revenue = profit - expense
      HyaccLogger.debug "今期末の利益：#{revenue}"
      
      # 今期の事業主借
      debt_account = Account.find_by_code(ACCOUNT_CODE_DEBT_TO_OWNER)
      debt_amount = VMonthlyLedger.get_net_sum_amount( nil, @fiscal_year.end_year_month, debt_account.id )
      HyaccLogger.debug "今期末の事業主借：#{debt_amount}"

      # 今期の事業主貸
      credit_account = Account.find_by_code(ACCOUNT_CODE_CREDIT_BY_OWNER)
      credit_amount = VMonthlyLedger.get_net_sum_amount( nil, @fiscal_year.end_year_month, credit_account.id )
      HyaccLogger.debug "今期末の事業主貸：#{credit_amount}"

      # 仕訳ヘッダ
      jh = @fiscal_year.get_carry_forward_journal
      if jh
        jh.journal_details.map(&:mark_for_destruction)
      else
        jh = JournalHeader.new(auto: true)
      end
      jh.company_id = @fiscal_year.company.id
      jh.fiscal_year_id = @fiscal_year.id
      jh.ym = HyaccDateUtil.next_month(@fiscal_year.end_year_month)
      jh.day = 1
      jh.slip_type = SLIP_TYPE_CARRY_FORWARD
      jh.remarks = "#{@fiscal_year.fiscal_year}年度繰越仕訳"
      jh.create_user_id = @user.id
      jh.update_user_id = @user.id
      
      # 元入金明細
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.detail_type = DETAIL_TYPE_NORMAL
      jd.dc_type = DC_TYPE_CREDIT
      jd.account_id = personal_capital_account.id
      jd.branch_id = @user.employee.default_branch.id
      jd.tax_type = TAX_TYPE_NONTAXABLE
      jd.amount = revenue + debt_amount - credit_amount
      if jd.amount < 0
        jd.amount *= -1
        jd.dc_type = DC_TYPE_DEBIT
      end
      jd.mark_for_destrunction if jd.amount == 0

      # 繰越利益剰余金明細
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.detail_type = DETAIL_TYPE_NORMAL
      jd.dc_type = DC_TYPE_DEBIT
      jd.account_id = Account.find_by_code(ACCOUNT_CODE_EARNED_SURPLUS_CARRIED_FORWARD).id
      jd.branch_id = @user.employee.default_branch.id
      jd.tax_type = TAX_TYPE_NONTAXABLE
      jd.amount = revenue
      if jd.amount < 0
        jd.amount *= -1
        jd.dc_type = DC_TYPE_CREDIT
      end
      jd.mark_for_destruction if jd.amount == 0

      # 事業主借明細
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.detail_type = DETAIL_TYPE_NORMAL
      jd.dc_type = DC_TYPE_DEBIT
      jd.account_id = debt_account.id
      jd.branch_id = @user.employee.default_branch.id
      jd.tax_type = TAX_TYPE_NONTAXABLE
      jd.amount = debt_amount
      jd.mark_for_destruction if jd.amount == 0

      # 事業主貸明細
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.detail_type = DETAIL_TYPE_NORMAL
      jd.dc_type = DC_TYPE_CREDIT
      jd.account_id = credit_account.id
      jd.branch_id = @user.employee.default_branch.id
      jd.tax_type = TAX_TYPE_NONTAXABLE
      jd.amount = credit_amount
      jd.mark_for_destruction if jd.amount == 0

      if jh.journal_details.find{|jd| ! jd.deleted? }
        jh
      else
        nil
      end
    end
  end
end
