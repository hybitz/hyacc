class ExemptionFinder
  include ActiveModel::Model
  include Pagination

  attr_accessor :company_id
  attr_accessor :employee_id
  attr_accessor :yyyy

  def list
    Exemption.where(conditions).order('yyyy desc', 'employee_id').paginate(:page => page, :per_page => per_page)
  end
  
  def employees
    Employee.where(:company_id => company_id, :deleted => false)
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('company_id = ?', company_id)
    sql.append('employee_id = ?', employee_id) if employee_id.present?
    sql.append('yyyy = ?', yyyy) if yyyy.present?
    sql.to_a
  end
end
