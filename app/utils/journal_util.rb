module JournalUtil
  include HyaccConst
  include HyaccErrors

  def self.build_rlike_condition(account_code, sub_account_id, branch_id)
    finder_key_rlike(account_code, sub_account_id, branch_id)
  end

  def self.escape_search(str)
    Daddy::Utils::SqlUtils.escape_search(str)
  end

  def self.finder_key_rlike(account_code, sub_account_id, branch_id)
    parts = ['.*-']

    # 勘定科目
    if account_code.present?
      parts << account_code.to_s
    else
      parts << '[0-9]*'
    end
    parts << ','

    # 補助科目
    if sub_account_id.to_i > 0
      parts << sub_account_id.to_s
    else
      parts << '[0-9]*'
    end
    parts << ','

    # 計上部門
    if branch_id.to_i > 0
      parts << branch_id.to_s
    else
      parts << '[0-9]*'
    end
    parts << '-.*'

    parts.join
  end

  # 伝票直前までの累計金額の取得
  def self.get_sum_until(slip, account_id, dc_type, branch_id, sub_account_id)
    # 伝票が1件もなければ累計は０円
    return 0 if slip.nil?

    sql = SqlBuilder.new
    sql.append('account_id = ?', account_id)
    sql.append('and journal_details.dc_type = ?', dc_type)
    sql.append('and (')
    sql.append('  journals.ym*100 + journals.day < ?', slip.ym * 100 + slip.day)
    sql.append('  or (')
    sql.append('    journals.ym*100 + journals.day = ?', slip.ym * 100 + slip.day)
    sql.append('    and')
    sql.append('    journals.id < ?', slip.journal.id)
    sql.append('  )')
    sql.append(')')
    sql.append('and branch_id = ? ', branch_id) if branch_id > 0
    sql.append('and sub_account_id = ?', sub_account_id) if sub_account_id > 0

    JournalDetail.joins(:journal).where(sql.to_a).sum('journal_details.amount')
  end

  def self.get_net_sum_until(slip, account, branch_id, sub_account_id)
    # 伝票がない場合
    return 0 if slip.nil?

    # accountが勘定科目コードの場合はマスタを検索
    if account.kind_of? String
      account = Account.find_by_code(account)
    # accountが勘定科目IDの場合はマスタ検索
    elsif account.kind_of? Fixnum
      account = Account.find(account)
    end
    return 0 unless account.kind_of? Account

    pre_sum_amount_increase = get_sum_until(slip, account.id, account.dc_type, branch_id, sub_account_id)
    pre_sum_amount_decrease = get_sum_until(slip, account.id, account.opposite_dc_type, branch_id, sub_account_id)
    HyaccUtil.subtract(pre_sum_amount_increase, pre_sum_amount_decrease)
  end

  # 現在の累計金額の取得
  def self.get_sum(company_id, account_id, dc_type, branch_id, sub_account_id)
    sql = SqlBuilder.new
    sql.append('account_id = ?', account_id)
    sql.append('and dc_type = ?', dc_type)
    sql.append('and branch_id = ?', branch_id) if branch_id.to_i > 0
    sql.append('and sub_account_id = ?', sub_account_id) if sub_account_id.to_i > 0
    sql.append('and exists (')
    sql.append('  select 1 from journals jh')
    sql.append('  where jh.id = journal_details.journal_id')
    sql.append('    and jh.company_id = ?', company_id)
    sql.append(')')

    JournalDetail.where(sql.to_a).sum(:amount)
  end

  def self.get_net_sum(company_id, account, branch_id, sub_account_id)
    # accountが勘定科目コードの場合はマスタを検索
    if account.kind_of? String
      account = Account.find_by_code( account )
    # accountが勘定科目IDの場合はマスタ検索
    elsif account.kind_of? Fixnum
      account = Account.find( account )
    end

    raise "勘定科目を特定できませんでした。account=#{account}" unless account.kind_of? Account

    sum_amount_increase = get_sum(company_id, account.id, account.dc_type, branch_id, sub_account_id)
    sum_amount_decrease = get_sum(company_id, account.id, account.opposite_dc_type, branch_id, sub_account_id)
    HyaccUtil.subtract(sum_amount_increase, sum_amount_decrease)
  end

  # 自動振替伝票かどうか
  def self.is_auto_transfer_journal( slip_type )
    [ SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_EXPENSE ].include?( slip_type )
  end

  # 部門別で貸借の金額が釣り合っているかどうか
  def self.is_balanced_by_branch( related_journals )
    balance_by_branch_map = make_balance_by_branch_map( related_journals )

    # 部門別に貸借の金額が釣り合っているか確認
    balance_by_branch_map.each_value{|value|
      if value.amount_debit != value.amount_credit
        return false
      end
    }

    true
  end

  def self.make_balance_by_branch_map( related_journals )
    balance_by_branch_map = {}

    related_journals.each{|jh|
      jh.journal_details.each do |detail|
        next if detail.marked_for_destruction?

        balance_by_branch = balance_by_branch_map[detail.branch_id]
        if balance_by_branch.nil?
          balance_by_branch = BalanceByBranch.new
          balance_by_branch.branch_id = detail.branch_id
          balance_by_branch_map[detail.branch_id] = balance_by_branch
        end

        # 貸借別に金額を集計する
        if detail.dc_type == DC_TYPE_DEBIT
          balance_by_branch.amount_debit += detail.amount
        elsif detail.dc_type == DC_TYPE_CREDIT
          balance_by_branch.amount_credit += detail.amount
        else
          # 貸借が不正
          raise HyaccException.new(ERR_ILLEGAL_STATE)
        end
      end
    }

    balance_by_branch_map
  end

  def self.validate_journal(new_journal, old_journal = nil)
    # 部門別貸借の確認
    unless is_balanced_by_branch(new_journal.get_all_related_journals)
      raise HyaccException.new(ERR_AMOUNT_UNBALANCED_BY_BRANCH)
    end

    # 締め状態の確認
    if old_journal
      validate_closing_status_on_update( new_journal, old_journal )
    else
      validate_closing_status_on_create( new_journal )
    end
  end

  # 配賦額を計算する
  def self.make_allocated_cost(journal_detail)
    case journal_detail.allocation_type
    when ALLOCATION_TYPE_EVEN_BY_SIBLINGS
      branches = journal_detail.branch.self_and_siblings
      make_allocation(journal_detail.amount, branches)
    when ALLOCATION_TYPE_SHARE_BY_EMPLOYEE
      branches = journal_detail.branch.self_and_descendants
      make_capitation(journal_detail.amount, branches, journal_detail.branch_id)
    when ALLOCATION_TYPE_EVEN_BY_CHILDREN
      branches = journal_detail.branch.children
      make_allocation(journal_detail.amount, branches)
    else
      raise "不正な配賦区分です。allocation_type=#{allocation_type}"
    end
  end

  def self.make_allocation(cost, branches)
    return {} if branches.empty?
  
    ret = {}
  
    costs = HyaccUtil.divide(cost, branches.size)
    branches.each_with_index do |b, i|
      ret[b] = costs[i]
    end
  
    ret
  end

  def self.make_capitation(cost, branches, parent_branch_id)
    ret = {}
    branch_ids = branches.pluck(:id)
    employee_counts = BranchEmployee
      .joins(:employee)
      .where(employees: {deleted: false, disabled: false})
      .where(branch_id: branch_ids, default_branch: true, deleted: false)
      .group(:branch_id)
      .count

    denominator = employee_counts.values.sum


    total = 0
    branch_for_leftover = nil

    branches.each do |b|
      numerator = employee_counts[b.id] || 0
      next if numerator == 0

      branch_for_leftover ||= b
      amount = cost * numerator / denominator
      ret[b] = amount
      total += amount
    end

    if branch_for_leftover.blank? || (ret.size == 1 && ret.keys.first.id == parent_branch_id)
      raise ERR_NO_CAPITATION_TARGET_BRANCH_EXISTS
    end

    if ret.values.all?{|v| v.to_i == 0}
      branch_for_leftover = ret.keys.find{|k| k.id != parent_branch_id}
    end

    ret[branch_for_leftover] += (cost - total)
    ret
  end

  # 伝票登録時の経理締めチェック
  def self.validate_closing_status_on_create(jh)
    closing_status = jh.fiscal_year.closing_status

    if HyaccLogger.debug?
      HyaccLogger.debug "登録時締め状態チェック: 新規伝票 => #{CLOSING_STATUS[closing_status]} #{jh.ym}/#{jh.day}:#{jh.remarks}"
    end

    # 仮締め
    if closing_status == CLOSING_STATUS_CLOSING
      # 自動振替伝票以外は登録できない
      unless is_auto_transfer_journal( jh.slip_type )
        raise HyaccException.new( ERR_CLOSING_STATUS_CLOSING )
      end
    # 本締め
    elsif closing_status == CLOSING_STATUS_CLOSED
      # すべての伝票の登録ができない
      raise HyaccException.new( ERR_CLOSING_STATUS_CLOSED )
    end

    # 自動仕訳の伝票が存在すればそれもチェック
    jh.transfer_journals.each do |tj|
      validate_closing_status_on_create( tj )
    end
    jh.journal_details.each do |jd|
      jd.transfer_journals.each do |tj|
        validate_closing_status_on_create( tj )
      end
    end
  end

  # 伝票削除時の経理締めチェック
  def self.validate_closing_status_on_delete( jh )
    closing_status = jh.fiscal_year.closing_status

    if HyaccLogger.debug?
      HyaccLogger.debug "削除時締め状態チェック：　削除伝票＝＞#{CLOSING_STATUS[closing_status]} #{jh.ym}/#{jh.day}:#{jh.remarks}"
    end

    # 仮締め
    if closing_status == CLOSING_STATUS_CLOSING
      # 自動振替伝票以外は削除できない
      unless is_auto_transfer_journal( jh.slip_type )
        raise HyaccException.new( ERR_CLOSING_STATUS_CLOSING )
      end
    # 本締め
    elsif closing_status == CLOSING_STATUS_CLOSED
      # すべての伝票の削除ができない
      raise HyaccException.new( ERR_CLOSING_STATUS_CLOSED )
    end

    # 自動仕訳の伝票が存在すればそれもチェック
    jh.transfer_journals.each do |tj|
      validate_closing_status_on_delete( tj )
    end
    jh.journal_details.each do |jd|
      jd.transfer_journals.each do |tj|
        validate_closing_status_on_delete( tj )
      end
    end
  end

  # 伝票更新時の経理締めチェック
  def self.validate_closing_status_on_update( jh, old )
    closing_status_old = old.fiscal_year.closing_status
    closing_status_new = jh.fiscal_year.closing_status

    if HyaccLogger.debug?
      HyaccLogger.debug "更新時締め状態チェック：　更新前伝票＝＞#{CLOSING_STATUS[closing_status_old]}　 #{jh.ym}/#{jh.day}:#{jh.remarks}　 " +
          "更新後伝票＝＞#{CLOSING_STATUS[closing_status_new]} #{jh.ym}/#{jh.day}:#{jh.remarks}"
    end

    # 修正前伝票が仮締め
    if closing_status_old == CLOSING_STATUS_CLOSING
      # 自動振替伝票以外は修正可能項目に制限あり
      unless is_auto_transfer_journal( old.slip_type )
        # 異なる会計年度への更新はNG
        unless jh.is_same_fiscal_year( old )
          raise HyaccException.new( ERR_CLOSING_STATUS_CLOSING )
        end
      end
    # 修正前伝票が本締め
    elsif closing_status_old == CLOSING_STATUS_CLOSED
      # すべての伝票の更新ができない
      raise HyaccException.new( ERR_CLOSING_STATUS_CLOSED )
    end

    # 修正後伝票が仮締め
    if closing_status_new == CLOSING_STATUS_CLOSING
      # 自動振替伝票以外は修正可能項目に制限あり
      unless is_auto_transfer_journal( jh.slip_type )
        # 異なる会計年度への更新はNG
        unless jh.is_same_fiscal_year( old )
          raise HyaccException.new( ERR_CLOSING_STATUS_CLOSING )
        end
      end
    # 修正後伝票が本締め
    elsif closing_status_new == CLOSING_STATUS_CLOSED
      # すべての伝票の更新ができない
      raise HyaccException.new( ERR_CLOSING_STATUS_CLOSED )
    end

    # 修正前の伝票に自動仕訳の伝票が存在すれば削除可能かチェック
    old.transfer_journals.each do |tj|
      validate_closing_status_on_delete( tj )
    end
    old.journal_details.each do |jd|
      jd.transfer_journals.each do |tj|
        validate_closing_status_on_delete( tj )
      end
    end

    # 修正後の伝票に自動仕訳の伝票が存在すれば作成可能かチェック
    jh.transfer_journals.each do |tj|
      validate_closing_status_on_create( tj )
    end
    jh.journal_details.each do |jd|
      jd.transfer_journals.each do |tj|
        validate_closing_status_on_create( tj )
      end
    end
  end

end
