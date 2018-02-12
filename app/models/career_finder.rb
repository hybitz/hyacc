class CareerFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware

  attr_accessor :employee_id

  def list
    if conditions.first.present?
      Career.where(conditions).order('start_from').paginate(:page => page, :per_page => per_page)
    else
      Career.order('start_from').paginate(:page => page, :per_page => per_page)
    end
  end

  def employees
    Employee.where(:company_id => company_id, :deleted => false)
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('employee_id = ?', employee_id) if employee_id.present?
    sql.to_a
  end
end
