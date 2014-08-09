module Reports
  class RentStatementLogic
    include JournalUtil

    def get_rent_statement(finder)
      rents = {}
      ym_start = get_start_year_month_of_fiscal_year( finder.fiscal_year, finder.start_month_of_fiscal_year)
      ym_end = get_end_year_month_of_fiscal_year( finder.fiscal_year, finder.start_month_of_fiscal_year)
      ymd_start = (ym_start.to_s + '01').to_i
      ymd_end = (ym_end.to_s + get_days_of_month(ym_end/100, ym_end%100).to_s).to_i

      Rent.order('status, ymd_end desc').each{|rent|
        rent.total_amount = 0
        rent.ymd_start = ymd_start if rent.ymd_start < ymd_start
        rent.ymd_end = ymd_end if rent.ymd_end.nil? || rent.ymd_end > ymd_end
        if rent.ymd_start > rent.ymd_end
          rent.remarks = "契約期間外の伝票"
        end
        rents[rent.id] = rent
      }

      # 端境期対応（通常は補助科目必須とする）
      rents['etc'] = Rent.new(:total_amount => 0, :address => '不明',
                              :remarks => '補助科目が指定されていない伝票',
                              :customer => Customer.new)
      JournalHeader.where(conditions(finder.branch_id, ym_start, ym_end)).includes(:journal_details).each do |jh|
        jh.journal_details.each do |jd|
          if jd.account.code == ACCOUNT_CODE_RENT
            sub_account_id = jd.sub_account_id || 'etc'
            if jd.dc_type == jd.account.dc_type
              rents[sub_account_id].total_amount += jd.amount
            else
              rents[sub_account_id].total_amount -= jd.amount
            end
          end
        end
      end

      rents.select{|id, rent| rent.total_amount > 0 }
    end

    private

    def conditions(branch_id, ym_start, ym_end)
      sql = SqlBuilder.new
      sql.append('deleted = ?', false)
      sql.append('and ym >= ? and ym <= ?', ym_start, ym_end)
      sql.append('and finder_key rlike ?', build_rlike_condition(ACCOUNT_CODE_RENT, 0, branch_id))
      sql.to_a
    end

  end
end
