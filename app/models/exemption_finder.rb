class ExemptionFinder
  include ActiveModel::Model
  include Pagination

  attr_accessor :company_id
  attr_accessor :employee_id
  attr_accessor :calendar_year

  def list
    Exemption.where(conditions).order('yyyy desc', 'employee_id').paginate(page: page, per_page: per_page)
  end
  
  def employees
    ret = Employee.where(company_id: company_id, deleted: false)
    if calendar_year.present?
      ret = ret.where('employment_date <= ? and (retirement_date is null or retirement_date >= ?)', "#{calendar_year}-12-31", "#{calendar_year}-01-01")
    end
    ret
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
