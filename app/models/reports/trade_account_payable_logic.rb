module Reports
  class TradeAccountPayableLogic < BaseLogic

    def build_model
      ret = TradeAccountPayableModel.new
  
      # 対象となる科目ごとに明細を組み立てる
      accounts = Account.where(:is_trade_account_payable => true).order('code')
      accounts.each do |a|
        if a.sub_accounts_all.present?
          a.sub_accounts_all.each do |sa|
            detail = TradeAccountPayableDetailModel.new
            detail.account = a
            if a.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
              detail.name = sa.name
              detail.address = sa.address
            else
              detail.name = sa.name
            end
            detail.amount_at_end = get_net_sum_amount(end_ym, a, sa.id)
            detail.remarks = a.short_description
            ret.add_detail(detail)
          end
        else
          detail = TradeAccountPayableDetailModel.new
          detail.account = a
          detail.amount_at_end = get_net_sum_amount(end_ym, a, 0)
          detail.remarks = a.short_description
          ret.add_detail(detail)
        end
      end
      
      # 金額が0円の明細を除去
      ret.details.delete_if do |d|
        d.amount_at_end == 0
      end
      
      ret
    end

    private

    def get_net_sum_amount(ym, account, sub_account_id)
      ret = 0

      sql = SqlBuilder.new
      sql.append('select')
      sql.append('  jd.dc_type,')
      sql.append('  sum(jd.amount) as amount')
      sql.append('from journal_details jd')
      sql.append('inner join journals jh on (jh.id = jd.journal_id)')
      sql.append('inner join accounts a on (a.id = jd.account_id)')
      sql.append('where ym <= ?', ym)
      sql.append('  and account_id = ?', account.id)
      sql.append('  and sub_account_id = ?', sub_account_id) if sub_account_id > 0
      sql.append('  and branch_id = ?', branch_id) if branch_id > 0
      sql.append('group by jd.dc_type')
      JournalDetail.find_by_sql(sql.to_a).each do |row|
        if row.dc_type == account.dc_type
          ret += row.amount.to_i
        else
          ret -= row.amount.to_i
        end
      end

      ret
    end
  end
end
