class ExemptionFinder
  include ActiveModel::Model
  include Pagination

  attr_accessor :company_id
  attr_accessor :employee_id
  attr_accessor :calendar_year

  def list
    Exemption.where(conditions).order('yyyy desc', 'employee_id').paginate(:page => page, :per_page => per_page)
  end
  
  def employees
    Employee.where(:company_id => company_id, :deleted => false)
  end

  def calendar_year_options
    {:include_blank => true}
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('company_id = ?', company_id)
    sql.append('and employee_id = ?', employee_id) if employee_id.present?
    sql.append('and yyyy = ?', calendar_year) if calendar_year.present?
    sql.to_a
  end

end
