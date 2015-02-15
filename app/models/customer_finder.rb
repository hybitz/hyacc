class CustomerFinder < Daddy::Model
  include HyaccConstants
  
  def disable_types
    DISABLE_TYPES.invert
  end

  def list
    Customer.where(conditions).not_deleted.order('code').paginate(:page => page, :per_page => per_page)
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('disabled = ?', BooleanUtils.to_b(disabled)) if disabled.present?
    sql.to_a
  end
end
