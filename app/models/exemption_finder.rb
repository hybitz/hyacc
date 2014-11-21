class ExemptionFinder < Daddy::Model

  def list
    Exemption.where(conditions).order('yyyy', 'employee_id').paginate(:page => page, :per_page => per_page)
  end
  
  def employee_id_enabled?
    true
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('employee_id = ?', employee_id) if employee_id.present?
    sql.append('yyyy = ?', yyyy) if yyyy.present?
    sql.to_a
  end
end
