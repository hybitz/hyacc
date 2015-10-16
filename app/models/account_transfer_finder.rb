class AccountTransferFinder < Daddy::Model
  include SlipTypes

  def list
    conditions = make_conditions

    # 初期検索でページングしていない時は一番最後（直近）のページを表示する
    unless self.page.present?
      total_count = JournalHeader.where(conditions).count
      if total_count > 0
        offset = total_count % per_page
        self.page = total_count / per_page + (offset > 0 ? 1 : 0)
      end

      self.page ||= 1
    end

    JournalHeader.where(conditions).paginate(:page => page, :per_page => per_page).order('ym, day, id')
  end

  def account_id
    super.to_i
  end

  def branch_id
    super.to_i
  end

  def branches
    @branches ||= Branch.get_branches(company_id)
  end

  def accounts
    @accounts ||= Account.get_journalizable_accounts
  end

  def to_account
    @account ||= Account.get(to_account_id)
  end

  def to_sub_accounts
    return [] unless to_account.present?
    @to_sub_accounts ||= to_account.sub_accounts.map{|sa| [sa.name, sa.id] }
  end

  private

  def make_conditions
    sql = SqlBuilder.new
    sql.append('deleted = ?', false)
    
    # 伝票区分
    if slip_types.present?
      sql.append('and slip_type in (?)', slip_types)
    end
    
    # 年月
    normalized_ym = ym.to_s.split('-').join
    if normalized_ym.to_i > 0
      sql.append('and ym like ?', "#{normalized_ym}%")
    end

    # 勘定科目または部門
    if account_id > 0 or branch_id > 0
      account_code = account_id > 0 ? Account.get(account_id).code : nil
      sql.append('and finder_key rlike ?', JournalUtil.finder_key_rlike(account_code, 0, branch_id))
    end

    # 摘要
    if remarks.present?
      sql.append('and remarks like ?', '%' + JournalUtil.escape_search(remarks) + '%')
    end

    sql.to_a
  end

end
