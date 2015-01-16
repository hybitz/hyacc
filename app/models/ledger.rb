class Ledger
  include HyaccUtil

  attr_accessor :id
  attr_accessor :ym
  attr_accessor :day
  attr_accessor :remarks
  attr_accessor :sub_account_id
  attr_accessor :amount_debit
  attr_accessor :amount_credit
  attr_accessor :account_name
  attr_accessor :branch_name
  attr_accessor :sub_account_name

  def initialize( journal_header, ledger_finder )
    setup_from_journal( journal_header, ledger_finder )
  end

  def setup_from_journal( journal_header, ledger_finder )
    self.id = journal_header.id
    self.ym = journal_header.ym
    self.day = journal_header.day
    self.remarks = journal_header.remarks
  
    # 簡易入力の場合は、相手科目の表示が可能
    if journal_header.slip_type == SLIP_TYPE_SIMPLIFIED
      if journal_header.journal_details.count(:conditions=>ledger_finder.conditions_for_journals()) == 1
        # 本伝票が前提としている科目側の明細を取得
        default_detail = journal_header.journal_details.find(
          :first,
          :conditions=>ledger_finder.conditions_for_journals()
        )
        
        # 金額
        if default_detail.dc_type == DC_TYPE_DEBIT
          self.amount_debit = default_detail.amount.to_i
        else
          self.amount_credit = default_detail.amount.to_i
        end
        
        # 相手勘定科目側の明細を取得
        target_detail = journal_header.journal_details.find(
          :first,
          :conditions => ['journal_details.id<>?', default_detail.id])
        
        # 相手勘定科目
        self.account_name = target_detail.account_name
        
        # 相手計上部門
        self.branch_name = target_detail.branch_name
        
        is_set = true
      end
    end
    
    # 諸口としての設定を行う場合
    unless is_set
      # 金額
      self.amount_debit = 0
      self.amount_credit = 0
      journal_header.journal_details.each do |jd|
        # 条件に一致する明細の場合は金額を加算
        if detail_matches?( ledger_finder, jd )
          self.amount_debit += jd.debit_amount
          self.amount_credit += jd.credit_amount
        end
      end
      
      # 相手勘定科目
      self.account_name = Account.get_by_code( ACCOUNT_CODE_VARIOUS ).name
    end
  end

  private

  def detail_matches?( ledger_finder, jd )
    if jd.account_id == ledger_finder.account_id
      if ledger_finder.sub_account_id == 0 || jd.sub_account_id == ledger_finder.sub_account_id
        ledger_finder.branch_id == 0 || jd.branch_id == ledger_finder.branch_id
      else
        false
      end
    else
      false
    end
  end

end
