class Ledger
  include HyaccConst

  attr_accessor :id
  attr_accessor :ym
  attr_accessor :day
  attr_accessor :remarks
  attr_accessor :sub_account_id
  attr_accessor :account
  attr_accessor :amount_debit
  attr_accessor :amount_credit
  attr_accessor :account_name
  attr_accessor :branch_name
  attr_accessor :sub_account_name

  def initialize( journal, ledger_finder )
    setup_from_journal( journal, ledger_finder )
  end

  def setup_from_journal( journal, ledger_finder )
    self.id = journal.id
    self.ym = journal.ym
    self.day = journal.day
    self.remarks = journal.remarks
    self.account = ledger_finder.account
    self.amount_credit = 0
    self.amount_debit = 0

    # 簡易入力の場合は、相手科目の表示が可能
    if journal.slip_type == SLIP_TYPE_SIMPLIFIED
      if journal.journal_details.where(ledger_finder.conditions_for_journals).count == 1
        # 本伝票が前提としている科目側の明細を取得
        default_detail = journal.journal_details.where(ledger_finder.conditions_for_journals).first

        # 金額
        if default_detail.dc_type == DC_TYPE_DEBIT
          self.amount_debit += default_detail.amount
        else
          self.amount_credit += default_detail.amount
        end

        # 相手勘定科目側の明細を取得
        target_detail = journal.journal_details.where('journal_details.id <> ?', default_detail.id).first
        
        # 相手勘定科目
        self.account_name = target_detail.account_name

        # 相手計上部門
        self.branch_name = target_detail.branch_name

        is_set = true
      end
    end

    # 諸口としての設定を行う場合
    unless is_set
      journal.journal_details.each do |jd|
        # 条件に一致する明細の場合は金額を加算
        if detail_matches?(ledger_finder, jd)
          self.amount_debit += jd.debit_amount
          self.amount_credit += jd.credit_amount
        end
      end

      # 相手勘定科目
      self.account_name = Account.find_by_code(ACCOUNT_CODE_VARIOUS).name
    end
  end

  def net_amount
    if account.credit?
      amount_credit - amount_debit
    else
      amount_debit - amount_credit
    end
  end

  private

  def detail_matches?( ledger_finder, jd )
    return false unless ledger_finder.account_id.to_i == jd.account_id 
    return false unless ledger_finder.sub_account_id.to_i == 0 or ledger_finder.sub_account_id.to_i == jd.sub_account_id
    return false unless ledger_finder.branch_id.to_i == 0 or ledger_finder.branch_id.to_i == jd.branch_id
    true
  end

end
