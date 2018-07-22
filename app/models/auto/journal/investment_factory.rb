module Auto::Journal

  class InvestmentFactory < Auto::AutoJournalFactory
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @investment = auto_journal_param.investment
      @user = auto_journal_param.user
    end
    
    def make_journals
      ret = []
      action = @investment.shares.to_i > 0 ? '取得' : '売却'
      account_code = @investment.for_what == SECURITIES_TYPE_FOR_TRADING ? ACCOUNT_CODE_TRADING_SECURITIES : ACCOUNT_CODE_INVESTMENT_SECURITIES
      branch_id = @user.employee.company.head_branch.id
      split = @investment.yyyymmdd.split("-")
      ym = split[0..1].join
      day = split[2]
      
      jh = JournalHeader.new
      jh.company = @user.employee.company
      jh.ym = ym
      jh.day = day
      jh.slip_type = SLIP_TYPE_INVESTMENT
      jh.remarks = Customer.find(@investment.customer_id).formal_name_on(@investment.yyyymmdd) + '株の' + action
      jh.create_user_id = @user.id
      jh.update_user_id = @user.id

      tax_rate = TaxJp.rate_on(jh.date)
      
       # 明細の作成
       ## 借方有価証券
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.dc_type = DC_TYPE_DEBIT
      jd.account_id = Account.find_by_code(account_code).id
      jd.branch_id = branch_id
      jd.tax_type = TAX_TYPE_NONTAXABLE
      jd.amount = @investment.trading_value.to_i
      @investment.journal_detail = jd
      
       # 仮払消費税
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.dc_type = DC_TYPE_DEBIT
      jd.account_id = Account.find_by_code(ACCOUNT_CODE_TEMP_PAY_TAX).id
      jd.branch_id = branch_id
      jd.detail_type = DETAIL_TYPE_TAX
      jd.amount = @investment.charges.to_i - (@investment.charges.to_i / 1 + tax_rate).ceil
      jd.tax_type = TAX_TYPE_NONTAXABLE
      tax_detail = jd
       
       ## 借方支払手数料
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.dc_type = DC_TYPE_DEBIT
      jd.account_id = Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id
      jd.branch_id = branch_id
      jd.amount = (@investment.charges.to_i / 1 + tax_rate).ceil
      jd.tax_type = TAX_TYPE_INCLUSIVE
      jd.tax_rate_percent = tax_rate * 100
      jd.allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
      jd.tax_detail = tax_detail
      
       ## 貸方預け金明細
      jd = jh.journal_details.build
      jd.detail_no = jh.journal_details.size
      jd.dc_type = DC_TYPE_CREDIT
      jd.account_id = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_PAID).id
      jd.sub_account_id = @investment.bank_account_id
      jd.branch_id = branch_id
      jd.amount = @investment.trading_value.to_i + @investment.charges.to_i
      jd.tax_type = TAX_TYPE_NONTAXABLE
      
      ret << jh
      ret
    end
  end
end
