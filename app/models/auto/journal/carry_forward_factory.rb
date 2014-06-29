module Auto::Journal
  
  # 個人事業主の年次繰越仕訳ファクトリ
  class CarryForwardFactory < Auto::AutoJournalFactory
    include HyaccDateUtil
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @fiscal_year = auto_journal_param.fiscal_year
      @user = auto_journal_param.user
    end

    def make_journals()
      # 今期の元入金
      personal_capital_account = Account.get_by_code(ACCOUNT_CODE_PERSONAL_CAPITAL)
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
      debt_account = Account.get_by_code(ACCOUNT_CODE_DEBT_TO_OWNER)
      debt_amount = VMonthlyLedger.get_net_sum_amount( nil, @fiscal_year.end_year_month, debt_account.id )
      HyaccLogger.debug "今期末の事業主借：#{debt_amount}"

      # 今期の事業主貸
      credit_account = Account.get_by_code(ACCOUNT_CODE_CREDIT_BY_OWNER)
      credit_amount = VMonthlyLedger.get_net_sum_amount( nil, @fiscal_year.end_year_month, credit_account.id )
      HyaccLogger.debug "今期末の事業主貸：#{credit_amount}"

      # 仕訳ヘッダ
      jh = @fiscal_year.get_carry_forward_journal
      jh = JournalHeader.new unless jh
      jh.company_id = @fiscal_year.company.id
      jh.fiscal_year_id = @fiscal_year.id
      jh.ym = next_month(@fiscal_year.end_year_month)
      jh.day = 1
      jh.slip_type = SLIP_TYPE_CARRY_FORWARD
      jh.remarks = "#{@fiscal_year.fiscal_year}年度繰越仕訳"
      jh.create_user_id = @user.id
      jh.update_user_id = @user.id
      jh.journal_details.clear
      
      # 元入金明細
      jd = JournalDetail.new
      jd.detail_no = 1
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
      jh.journal_details << jd if jd.amount != 0
      
      # 繰越利益剰余金明細
      jd2 = JournalDetail.new
      jd2.detail_no = 2
      jd2.detail_type = DETAIL_TYPE_NORMAL
      jd2.dc_type = DC_TYPE_DEBIT
      jd2.account_id = Account.get_by_code(ACCOUNT_CODE_EARNED_SURPLUS_CARRIED_FORWARD).id
      jd2.branch_id = @user.employee.default_branch.id
      jd2.tax_type = TAX_TYPE_NONTAXABLE
      jd2.amount = revenue
      if jd2.amount < 0
        jd2.amount *= -1
        jd2.dc_type = DC_TYPE_CREDIT
      end
      jh.journal_details << jd2 if jd2.amount != 0

      # 事業主借明細
      jd3 = JournalDetail.new
      jd3.detail_no = 3
      jd3.detail_type = DETAIL_TYPE_NORMAL
      jd3.dc_type = DC_TYPE_DEBIT
      jd3.account_id = debt_account.id
      jd3.branch_id = @user.employee.default_branch.id
      jd3.tax_type = TAX_TYPE_NONTAXABLE
      jd3.amount = debt_amount
      jh.journal_details << jd3 if jd3.amount != 0

      # 事業主貸明細
      jd4 = JournalDetail.new
      jd4.detail_no = 4
      jd4.detail_type = DETAIL_TYPE_NORMAL
      jd4.dc_type = DC_TYPE_CREDIT
      jd4.account_id = credit_account.id
      jd4.branch_id = @user.employee.default_branch.id
      jd4.tax_type = TAX_TYPE_NONTAXABLE
      jd4.amount = credit_amount
      jh.journal_details << jd4 if jd4.amount != 0

      if jh.journal_details.size > 0
        jh
      else
        nil
      end
    end
  end
end
