class SimpleSlipTemplateFinder < Daddy::Model
  
  def list
    ret = SimpleSlipTemplate.where(conditions).includes([:account, :branch]).order('remarks')
    ret = ret.paginate(page: page, per_page: per_page)
  end

  def sub_accounts
    @account ||= Account.find(account_id) if account_id.present?
    @account ? @account.sub_accounts : []
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('simple_slip_templates.deleted = ?', false)
    sql.append('and account_id = ?', account_id) if account_id.present?
    sql.append('and remarks like ?', "%#{remarks}%") if remarks.present?
    sql.to_a
  end
end
