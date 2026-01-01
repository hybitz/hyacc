class ExemptionFinder
  include ActiveModel::Model
  include Pagination
  include CalendarYearAware

  attr_accessor :company_id
  attr_accessor :employee_id

  def list
    Exemption.where(conditions).order('yyyy desc', 'employee_id').paginate(page: page, per_page: per_page)
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
