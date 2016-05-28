module Reports
  class TradeAccountPayableLogic
    include HyaccConstants

    def get_trade_account_payable_model(finder)
      ret = Reports::TradeAccountPayableModel.new
  
      # 期末の年月
      end_ym = HyaccDateUtil.get_end_year_month_of_fiscal_year( finder.fiscal_year, finder.start_month_of_fiscal_year )
  
      # 対象となる科目ごとに明細を組み立てる
      accounts = Account.where(:is_trade_account_payable => true).order('code')
      accounts.each do |a|
        if a.sub_accounts_all.present?
          a.sub_accounts_all.each do |sa|
            detail = Reports::TradeAccountPayableDetailModel.new
            detail.account = a
            if a.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
              detail.name = sa.name
              detail.address = sa.address
            elsif a.sub_account_type == SUB_ACCOUNT_TYPE_EMPLOYEE
              detail.name = sa.employee.fullname
            else
              detail.name = sa.name
            end
            detail.amount_at_end = VMonthlyLedger.get_net_sum_amount(nil, end_ym, a.id, sa.id, finder.branch_id, :include_children => false)
            detail.remarks = a.short_description
            ret.add_detail(detail)
          end
        else
          detail = Reports::TradeAccountPayableDetailModel.new
          detail.account = a
          detail.amount_at_end = VMonthlyLedger.get_net_sum_amount(nil, end_ym, a.id, 0, finder.branch_id, :include_children => false)
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
  end
end
