class CareerFinder < Daddy::Model

  def list
    Career.where(conditions).order('start_from').paginate(:page => page, :per_page => per_page)
  end

  def employee_id_enabled?
    true
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('employee_id = ?', employee_id) if employee_id.present?
    sql.to_a
  end
end
