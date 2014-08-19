class BankFinder < Daddy::Model

  def deleted?
    deleted.to_s.downcase == 'true'
  end
  
  def list(options = {})
    Bank.where(conditions).order('code')
        .paginate(:page => page.to_i > 0 ? page : 1, :per_page => options[:per_page] || DEFAULT_PER_PAGE)
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('deleted = ?', deleted?) if deleted.present?
    sql.to_a
  end
end
