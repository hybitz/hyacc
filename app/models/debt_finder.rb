class DebtFinder < Base::Finder
  include HyaccConst

  def list
    ret = []
    sum = 0
    jhs = Journal.where(conditions).includes(:journal_details).order('ym desc, day desc, journals.created_at desc').reverse
    
    # 仮負債の明細ごとにリスト化する
    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    jhs.each do |jh|
      jh.journal_details.where('account_id = ? and branch_id = ?', a.id, branch_id).each do |jd|
        d = Debt.new
        d.id = jh.id
        d.ym = jh.ym
        d.day = jh.day
        # Trac#140 明細から派生する自動仕訳をJournalではなくJournalDetailに関連付けるようにしました。
        # 既存のデータはヘッダに関連付いています。
        if jh.transfer_from_id
          d.remarks = Journal.find(jh.transfer_from_id).remarks
          d.transfer_from_id = jh.transfer_from_id
        # 今後登録されるデータは明細に関連付いています。
        else
          src_jh = JournalDetail.find(jh.transfer_from_detail_id).journal
          d.remarks = src_jh.remarks
          d.transfer_from_id = src_jh.id
        end

        d.amount = jd.amount
        d.branch_id = jd.branch_id
        d.branch_name = jd.branch_name
        d.opposite_branch_id = jd.sub_account_id
        d.opposite_branch_name = jd.sub_account_name
        d.closed_id = closed_id(jh, jd.branch_id)
        sum += jd.amount unless d.closed_id
        ret << d
      end
    end
    
    return ret, sum
  end

  protected

  # 仮負債精算済みかを判定し、精算した伝票IDを取得
  def closed_id(jh, branch_id)
    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    jh.transfer_journals.each do |tjh|
      tjh.journal_details.each do |jd|
        if branch_id == jd.branch_id and
           a.id == jd.account_id and
           DC_TYPE_DEBIT == jd.dc_type
          return tjh.id
        end
      end
    end

    nil
  end

  def conditions
    sql = SqlBuilder.new
    sql.append('deleted = ?', false)
    sql.append('and ym >= ?', HyaccDateUtil.get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year ))
    sql.append('and ym <= ?', HyaccDateUtil.get_end_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year ))
    sql.append('and finder_key rlike ?', JournalUtil.build_rlike_condition( ACCOUNT_CODE_TEMPORARY_DEBT, 0, branch_id ))
    sql.append('and slip_type <> ?', SLIP_TYPE_TEMPORARY_DEBT)
    sql.to_a
  end

end
