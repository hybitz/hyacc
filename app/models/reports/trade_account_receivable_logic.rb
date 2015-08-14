module Reports
  class TradeAccountReceivableLogic
    include HyaccDateUtil

    def get_trade_account_receivable_model(finder)
      res = []
      ymd = finder.end_year_month_day_of_fiscal_year.to_s
      a = Account.get_by_code(ACCOUNT_CODE_RECEIVABLE)
      
      # 借方
      debits = JournalDetail.where(:account_id => a.id, :dc_type=>DC_TYPE_DEBIT).joins(:journal_header).where(JournalHeader.arel_table[:ym].lteq ymd[0, 6]).group(:sub_account_id).sum(:amount)
      # 貸方
      credits = JournalDetail.where(:account_id => a.id, :dc_type=>DC_TYPE_CREDIT).joins(:journal_header).where(JournalHeader.arel_table[:ym].lteq ymd[0, 6]).group(:sub_account_id).sum(:amount)

      debits.each do |key, value|
        sum = 0
        sum = value - credits[key] unless credits[key].nil?
        if sum > 0
          c = Customer.find(key).customer_names.where('start_date < ?', ymd.to_date).order('start_date DESC').first
          raise HyaccException.new("取引先情報の取得に失敗") if c.nil?
          t = Reports::TradeAccountReceivableModel.new
          t.customer_id = key
          t.customer_name = c.formal_name
          t.account_receivable = sum
          t.address = Customer.find(key).address
          res.push(t)
        end
      end
      res
    end
  end
end
