class InvestmentFinder
  include ActiveModel::Model
  include HyaccConst
  include Pagination
  include CompanyAware
  include BankAccountAware

  attr_accessor :fiscal_year
  attr_accessor :order

  def list
    Investment.where(conditions).order(order)
  end
  
  def fiscal_years
    company.fiscal_years.map{|fy| fy.fiscal_year }.sort
  end
  
  def order
    @order || 'ym, day'
  end
  
  def is_not_related_to_journal
    journals_for_investment.where(investment_id: nil).exists?
  end

  def journals_not_related
    journals_for_investment.where(investment_id: nil)
  end

  # 伝票一枚に対して有価証券明細は一つであると想定する。複数ある場合は最後の明細で上書きされる。
  def journals_for_investment
    investment_account_ids = Account.where(Account.arel_table[:path].matches('%' + ACCOUNT_CODE_SECURITIES + '%')).pluck(:id)
    Journal
      .joins(:journal_details)
      .where(journal_details: { account_id: investment_account_ids })
      .distinct
  end
  
  def set_investment_from_journal(journal_id)
    investment = Investment.new
    investment_ids = Account.where(Account.arel_table[:path].matches('%' + ACCOUNT_CODE_SECURITIES + '%')).pluck(:id)
    paid_fee_id = Account.find_by_code(ACCOUNT_CODE_PAID_FEE).id
    deposits_paid_id = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_PAID).id
    investment_securities_id = Account.find_by_code(ACCOUNT_CODE_INVESTMENT_SECURITIES).id

    jh = Journal.find(journal_id)
    investment.journal = jh
    investment.yyyymmdd = jh.ym.to_s.insert(4, '-') + '-' + "%02d" % jh.day.to_s

    jh.journal_details.each do |jd|
      if investment_ids.include?(jd.account_id)
        investment.buying_or_selling = jd.dc_type == DC_TYPE_DEBIT ? '1' : '0'
        investment.for_what = jd.account_id == investment_securities_id ? SECURITIES_TYPE_FOR_INVESTMENT : SECURITIES_TYPE_FOR_TRADING
        investment.trading_value = jd.amount
      end
      if paid_fee_id == jd.account_id
        investment.charges = jd.amount
      end
      # 預け金明細の補助科目（証券口座）を bank_account_id に引き継ぐ
      if jd.account_id == deposits_paid_id && jd.sub_account_id.present?
        investment.bank_account_id = jd.sub_account_id
      end
    end

    investment
  end
  
  private

  def conditions
    ym_range = get_ym_range
    sql = SqlBuilder.new
    sql.append('bank_account_id = ? and ym >= ? and ym <= ?', self.bank_account_id, ym_range.first, ym_range.last)
    sql.to_a
  end

  # 会計年度内の年月を12ヶ月分、yyyymmの配列として取得する。
  def get_ym_range
    start_year_month = HyaccDateUtil.get_start_year_month_of_fiscal_year(fiscal_year, company.start_month_of_fiscal_year)
    HyaccDateUtil.get_year_months(start_year_month, 12)
  end
  
end