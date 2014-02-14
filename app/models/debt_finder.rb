# coding: UTF-8
#
# $Id: debt_finder.rb 3126 2013-08-15 05:22:08Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class DebtFinder < Base::Finder
  include JournalUtil

  def setup_from_params( params )
    super(params)
  end

  def list
    ret = []
    sum = 0
    jhs = JournalHeader.find(:all, :conditions=>make_conditions,
      :include=>[:journal_details],
      :order=>"ym desc, day desc, journal_headers.created_on desc").reverse
    
    # 仮負債の明細ごとにリスト化する
    a = Account.get_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    key_branch_id = branch_id
    key_branch_id = "[0-9]*" if branch_id == 0
    jhs.each do |jh|
      d = Debt.new
      d.id = jh.id
      d.ym = jh.ym
      d.day = jh.day
      
      # Trac#140 明細から派生する自動仕訳をJournalHeaderではなくJournalDetailに関連付けるようにしました。
      # 既存のデータはヘッダに関連付いています。
      if jh.transfer_from_id
        d.remarks = JournalHeader.find(jh.transfer_from_id).remarks
        d.transfer_from_id = jh.transfer_from_id
      # 今後登録されるデータは明細に関連付いています。
      else
        src_jh = JournalDetail.find(jh.transfer_from_detail_id).journal_header
        d.remarks = src_jh.remarks
        d.transfer_from_id = src_jh.id
      end
    
      jh.journal_details.find(:all, :conditions=>["account_id=? and branch_id rlike ?", a.id, key_branch_id]).each do |jd|
        dummy = Marshal.load(Marshal.dump(d))
        dummy.amount = jd.amount
        dummy.branch_id = jd.branch_id
        dummy.branch_name = jd.branch_name
        dummy.opposite_branch_id = jd.sub_account_id
        dummy.opposite_branch_name = jd.sub_account_name
        dummy.closed_id = closed_id(jh, jd.branch_id)
        sum += jd.amount unless dummy.closed_id
        ret << dummy
      end
    end
    
    return ret, sum
  end

protected
  # 仮負債精算済みかを判定し、精算した伝票IDを取得
  def closed_id(jh, branch_id)
    a = Account.get_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    jh.transfer_journals.each do |tjh|
      tjh.journal_details.each do |jd|
        if branch_id == jd.branch_id and
           a.id == jd.account_id and
           DC_TYPE_DEBIT == jd.dc_type
          return tjh.id
        end
      end
    end
    return nil
  end

  # 検索条件を作成する
  def make_conditions
    conditions = []

    # 年月
    conditions[0] = "ym >= ? "
    conditions << get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    conditions[0] << "and ym <= ? "
    conditions << get_end_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )

    # 検索キー
    conditions[0] << "and finder_key rlike ? "
    conditions << build_rlike_condition( ACCOUNT_CODE_TEMPORARY_DEBT, 0, branch_id )
    conditions[0] << "and slip_type<>? "
    conditions << SLIP_TYPE_TEMPORARY_DEBT
    
    conditions
  end

end
