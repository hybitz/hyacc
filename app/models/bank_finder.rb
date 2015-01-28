class BankFinder < Daddy::Model

  def deleted?
    deleted.to_s.downcase == 'true'
  end
  
  def list
    Bank.where(conditions).order('code')
        .paginate(:page => page || 1, :per_page => per_page || DEFAULT_PER_PAGE)
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('deleted = ?', deleted?) if deleted.present?
    sql.to_a
  end
end
