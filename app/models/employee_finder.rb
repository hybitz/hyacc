class EmployeeFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware

  attr_accessor :disabled

  def disabled_types
    DISABLED_TYPES.invert
  end

  def list
    Employee.where(conditions).paginate(page: page, per_page: per_page)
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('company_id = ?', company_id)
    sql.append('and disabled = ?', BooleanUtils.to_b(disabled)) if disabled.present?
    sql.append('and deleted = ?', false)
    sql.to_a
  end

end
