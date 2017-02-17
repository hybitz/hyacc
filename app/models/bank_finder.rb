class BankFinder < Daddy::Model
  include HyaccConstants

  def disable_types
    DISABLE_TYPES.invert
  end

  def list
    if conditions.first.present?
      Bank.where(conditions).order('code').paginate(:page => page, :per_page => per_page || DEFAULT_PER_PAGE)
    else
      Bank.order('code').paginate(:page => page, :per_page => per_page || DEFAULT_PER_PAGE)
    end
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('disabled = ?', BooleanUtils.to_b(disabled)) if disabled.present?
    sql.to_a
  end
end
